from pyspark.sql.types import StructType, StructField, StringType, ShortType, IntegerType, DoubleType, TimestampType, BooleanType, ArrayType, MapType, Row
from datetime import datetime as dt
import pandas as pd
import uuid


def append_with_prefix(field):
    if "prefix" in field.keys():
        return field["prefix"] + field["fieldName"]
    return field["fieldName"]


def remove_tz_wordings(datetime_value, format):
    wordings = ["(Coordinated Universal Time)", "(Eastern European Summer Time)"]
    for wording in wordings:
        datetime_value = str(datetime_value).replace(wording, "")
    try:
        dt.strptime(datetime_value, format)
        return datetime_value
    except ValueError:
        date_obj = dt.strptime(datetime_value, '%a %b %d %Y %H:%M:%S GMT%z ')
        formatted_date_str = date_obj.strftime('%Y-%m-%dT%H:%M:%S.%f') + 'Z'
        return formatted_date_str
    #return datetime_value


def get_nested_element(field, source_record_row):
    path_elmnts = field["parent"].split(".")
    path_elmnts.append(field["fieldName"])
    path_elmnts.remove("data")
    for lvl in path_elmnts:
        # if "cropDescriptionId" in path_elmnts:
        #     print(path_elmnts)
        #     print(source_record_row)
        #     print(lvl)
        if source_record_row is not None and lvl in list(source_record_row.asDict()):
            source_record_row = source_record_row[lvl]
        else:
            return None
    return source_record_row


def getAllTuples(SourcePDF, schema_obj, avro_file_path, glue_logger, log_former):
    list_of_all_tuples = []

    for idx in range(SourcePDF.shape[0]):
        tpl = ()
        data_list = list(SourcePDF["data"][idx].asDict())
        print(f"Data list: {data_list}")
        all_columns_list = SourcePDF.columns

        for field in schema_obj:

            if field["parent"] is None:
                print(field["parent"])
                print(field["fieldName"])
                if field["fieldName"] in SourcePDF.columns:
                    print(SourcePDF[field["fieldName"]][idx])
                else:
                    print("None value")
                if field["fieldName"] == "created_at":
                    if schema_obj[0]["fieldName"] == "dateTimeOccurred":
                        tpl += (str(str(remove_tz_wordings(SourcePDF['dateTimeOccurred'][idx],"%Y-%m-%dT%H:%M:%S.%fZ"))[:10]),)
                    # if schema_obj[0]["fieldName"] == "dateTimeOccurred" and 'dateTimeFormat' in schema_obj[0].keys():
                    #     tpl += (str(str(dt.strptime(remove_tz_wordings(SourcePDF['dateTimeOccurred'][idx]),
                    #                                 schema_obj[0]["dateTimeFormat"]))[:10]),)
                    # else:
                    #     tpl += (str((SourcePDF['dateTimeOccurred'][idx])[:10]),)
                elif "isGenerated" in field.keys() and field["isGenerated"]:
                    tpl += (str(uuid.uuid4()),)
                elif "isComposite" in field.keys() and field["isComposite"]:
                    # This is for composite - merged fields from existing
                    elements_list = field["compositeElements"].split(',')
                    delimiter = field.get("compositeDelimiter", "-")
                    logger.info(log_former.get_message(f"Elements in composite: {elements_list}"))

                    element_array = []
                    for element in elements_list:
                        if 'data' in element:
                            # for nested elements - only 'data' is allowed as of now
                            tmp_field = {
                                'parent': 'data',
                                'fieldName': element.replace("data.", "")
                            }
                            elementField = str(get_nested_element(tmp_field, SourcePDF["data"][idx]))
                        else:
                            # regular element
                            elementField = str(SourcePDF[element][idx])
                        # append found value
                        element_array.append(elementField)
                    # merge all values with delimiter
                    composite_string = delimiter.join(element_array)
                    logger.info(log_former.get_message(f"Elements data final composite: {composite_string}"))
                    tpl += (str(composite_string),)
                elif field["fieldName"] == "avroFilePath":
                    tpl += (avro_file_path,)
                else:
                    if field["fieldName"] in all_columns_list:
                        if pd.isna(SourcePDF[field["fieldName"]][idx]):
                            tpl += (None,)
                        elif field["type"] in "StringType":
                            tpl += (str(SourcePDF[field["fieldName"]][idx]),)
                        elif field["type"] in "IntegerType":
                            tpl += (int(SourcePDF[field["fieldName"]][idx]),)
                        elif field["type"] in "ShortType":
                            tpl += (int(SourcePDF[field["fieldName"]][idx]),)
                        elif field["type"] in "BooleanType":
                            tpl += (SourcePDF[field["fieldName"]][idx],)
                        elif field["type"] in "DoubleType":
                            tpl += (float(SourcePDF[field["fieldName"]][idx]),)
                        elif field["type"] == "TimestampType":
                            tpl += (dt.strptime(remove_tz_wordings(SourcePDF[field["fieldName"]][idx],"%Y-%m-%dT%H:%M:%S.%fZ"), '%Y-%m-%dT%H:%M:%S.%fZ'),)
                            # if "dateTimeFormat" in field.keys():
                            #     tpl += (dt.strptime(remove_tz_wordings(SourcePDF[field["fieldName"]][idx]),
                            #                         field["dateTimeFormat"]),)
                            # else:
                            #     tpl += (dt.strptime(SourcePDF[field["fieldName"]][idx], '%Y-%m-%dT%H:%M:%S.%fZ'),)
                        elif field["type"] == "UUIDType":
                            tpl += (str(SourcePDF[field["fieldName"]][idx]),)
                        else:
                            tpl += (str(SourcePDF[field["fieldName"]][idx]),)
                    else:
                        tpl += (None,)
            elif field["parent"] == 'data' or len(field["parent"].split(".")) > 1:
                print(field["fieldName"])
                print(field["parent"])
                test_tpl = get_nested_element(field, SourcePDF["data"][idx])
                print(test_tpl)
                if "isMergedTo" in field.keys():
                    pass
                elif test_tpl is None:
                    is_none = True
                    for chck_fld in schema_obj:
                        if "isMergedTo" in chck_fld.keys():
                            if chck_fld["isMergedTo"] == (field['parent'] + "." + field['fieldName']):
                                print("Field has merged attributes")
                                print(f"{chck_fld['parent']}.{chck_fld['fieldName']}")
                                value = get_nested_element(chck_fld, SourcePDF["data"][idx])
                                print(f"the value of the merged attribute is: {value}")
                                if value is None:
                                    pass
                                else:
                                    is_none = False
                                    if chck_fld["type"] in "StringType":
                                        tpl += (str(value),)
                                    elif chck_fld["type"] in "ShortType":
                                        tpl += (int(value),)
                                    elif chck_fld["type"] in "IntegerType":
                                        tpl += (int(value),)
                                    elif chck_fld["type"] in "DoubleType":
                                        tpl += (float(value),)
                                    elif chck_fld["type"] == "TimestampType":
                                        tpl += (dt.strptime(value, '%Y-%m-%dT%H:%M:%S.%fZ'),)
                                    elif chck_fld["type"] in "UUIDType":
                                        tpl += (str(value),)
                                    elif chck_fld["type"] == "ArrayType":
                                        array_dict = []
                                        for aitem in value:
                                            print((aitem.asDict()).keys())
                                            item_test = {}
                                            for attr in list((aitem.asDict()).keys()):
                                                print(attr)
                                                if isinstance(aitem[attr], Row):
                                                    item_test[attr] = str(aitem[attr].asDict()).replace('"',
                                                                                                        '\\"').replace(
                                                        "'", '"')
                                                else:
                                                    item_test[attr] = aitem[attr]
                                            array_dict.append(item_test)
                                        tpl += (array_dict,)
                                    else:
                                        tpl += (str(value),)
                    if is_none:
                        print("printing None for the value")
                        tpl += (None,)
                else:
                    if field["type"] in "StringType":
                        tpl += (str(test_tpl),)
                    elif field["type"] in "ShortType":
                        tpl += (int(test_tpl),)
                    elif field["type"] in "IntegerType":
                        tpl += (int(test_tpl),)
                    elif field["type"] in "DoubleType":
                        tpl += (float(test_tpl),)
                    elif field["type"] == "TimestampType":
                        tpl += (dt.strptime(test_tpl, '%Y-%m-%dT%H:%M:%S.%fZ'),)
                    elif field["type"] in "UUIDType":
                        tpl += (str(test_tpl),)
                    elif field["type"] == "ArrayType":
                        array_dict = []
                        for aitem in test_tpl:
                            item_test = {}
                            for attr in list((aitem.asDict()).keys()):
                                if isinstance(aitem[attr], Row):
                                    item_test[attr] = str(aitem[attr].asDict()).replace('"', '\\"').replace("'", '"')
                                else:
                                    item_test[attr] = aitem[attr]
                            array_dict.append(item_test)
                        tpl += (array_dict,)
                    else:
                        tpl += (str(test_tpl),)
        list_of_all_tuples.append(tpl)
    glue_logger.info(log_former.get_message("List of tuples created."))
    print("List of tuples created.")
    print(list_of_all_tuples)
    return list_of_all_tuples


def getUpsertTuplesFlat(SourcePDF, schema_obj, pk_field_name, glue_logger, log_former):
    list_of_tuples = []

    for idx in range(SourcePDF.shape[0]):
        tpl = ()
        to_be_skipped = False
        for field in schema_obj:
            fieldName = append_with_prefix(field)
            print(f"field to be processed: {fieldName}")
            if "isMergedTo" not in field.keys():
                if pk_field_name == fieldName and (
                        SourcePDF[fieldName][idx] is None or str(SourcePDF[fieldName][idx]) == ""):
                    """Busines rule: to exclude the records that have no or empty IDs (initially introduced for SoilAnalysisCalculatedV2Requested)"""
                    to_be_skipped = True
                    continue
                if SourcePDF[fieldName][idx] is None:
                    tpl += (None,)
                elif field["type"] == "ArrayType":
                    array_dict = []
                    for aitem in SourcePDF[fieldName][idx]:
                        print(f"The Item of array: {aitem}")
                        print((aitem.asDict()).keys())
                        item_test = {}
                        for attr in list((aitem.asDict()).keys()):
                            print(attr)
                            if isinstance(aitem[attr], Row):
                                item_test[attr] = str(aitem[attr].asDict()).replace('"', '\\"').replace("'", '"')
                            else:
                                item_test[attr] = aitem[attr]
                        array_dict.append(item_test)
                    tpl += (array_dict,)
                elif pd.isna(SourcePDF[fieldName][idx]):
                    tpl += (None,)
                elif field["type"] == "StringType":
                    tpl += (str(SourcePDF[fieldName][idx]),)
                elif field["type"] == "ShortType":
                    tpl += (int(SourcePDF[fieldName][idx]),)
                elif field["type"] == "IntegerType":
                    tpl += (int(SourcePDF[fieldName][idx]),)
                elif field["type"] == "DoubleType":
                    tpl += (float(SourcePDF[fieldName][idx]),)
                elif field["type"] in "BooleanType":
                    tpl += (SourcePDF[fieldName][idx],)
                elif field["type"] == "TimestampType":
                    tpl += (SourcePDF[fieldName][idx].to_pydatetime(),)
                elif field["type"] == "UUIDType":
                    tpl += (str(SourcePDF[fieldName][idx]),)
                else:
                    tpl += (str(SourcePDF[fieldName][idx]),)
        if not to_be_skipped:
            list_of_tuples.append(tpl)

    glue_logger.info(log_former.get_message("List of tuples created."))
    return list_of_tuples


def getDeleteTuplesFlat(SourcePDF, schema_obj, glue_logger, log_former):
    list_of_tuples = []

    for idx in range(SourcePDF.shape[0]):
        tpl = ()
        for field in schema_obj:
            fieldName = append_with_prefix(field)
            if "isMergedTo" not in field.keys():
                if SourcePDF[fieldName][idx] is None:
                    tpl += (None,)
                elif field["isPIIData"]:
                    tpl += (None,)
                elif field["type"] == "ArrayType":
                    array_dict = []
                    for aitem in SourcePDF[field["fieldName"]][idx]:
                        print(f"The Item of array: {aitem}")
                        print((aitem.asDict()).keys())
                        item_test = {}
                        for attr in list((aitem.asDict()).keys()):
                            print(attr)
                            if isinstance(aitem[attr], Row):
                                item_test[attr] = str(aitem[attr].asDict()).replace('"', '\\"').replace("'", '"')
                            else:
                                item_test[attr] = aitem[attr]
                        array_dict.append(item_test)
                    tpl += (array_dict,)
                elif field["type"] == "StringType":
                    tpl += (str(SourcePDF[fieldName][idx]),)
                elif field["type"] == "ShortType":
                    tpl += (int(SourcePDF[fieldName][idx]),)
                elif field["type"] == "IntegerType":
                    tpl += (int(SourcePDF[fieldName][idx]),)
                elif field["type"] in "BooleanType":
                    tpl += (SourcePDF[fieldName][idx],)
                elif field["type"] == "DoubleType":
                    tpl += (float(SourcePDF[fieldName][idx]),)
                elif field["type"] == "UUIDType":
                    tpl += (str(SourcePDF[fieldName][idx]),)
                elif field["type"] == "TimestampType":
                    tpl += (SourcePDF[fieldName][idx].to_pydatetime(),)
                else:
                    tpl += (str(SourcePDF[fieldName][idx]),)
        list_of_tuples.append(tpl)

    glue_logger.info(log_former.get_message("List of tuples created."))
    return list_of_tuples


def get_schema(schema_obj):
    list_of_fields = []
    list_of_fields_flat = []
    fields = []
    for field in schema_obj:
        fieldName = append_with_prefix(field)
        if "isMergedTo" not in field.keys():
            if field["type"] == "ShortType":
                fields.append(StructField(fieldName, ShortType(), field["isNullable"]))
            elif field["type"] == "IntegerType":
                fields.append(StructField(fieldName, IntegerType(), field["isNullable"]))
            elif field["type"] == "DoubleType":
                fields.append(StructField(fieldName, DoubleType(), field["isNullable"]))
            elif field["type"] == "TimestampType":
                fields.append(StructField(fieldName, TimestampType(), field["isNullable"]))
            elif field["type"] == "UUIDType":
                fields.append(StructField(fieldName, StringType(), field["isNullable"]))
                # elif field["type"] == "BooleanType":
            #     fields.append(StructField(fieldName, BooleanType(), field["isNullable"]))
            elif field["type"] == "ArrayType":
                array_items = field["contentOfArray"].split('|')
                recs = []
                for item in array_items:
                    field_item = item.split(',')
                    if field_item[1] == "StringType":
                        recs.append(StructField(field_item[0], StringType(), field["isNullable"]))
                    elif field_item[1] == "ShortType":
                        recs.append(StructField(field_item[0], ShortType(), field["isNullable"]))
                    elif field_item[1] == "IntegerType":
                        recs.append(StructField(field_item[0], IntegerType(), field["isNullable"]))
                    elif field_item[1] == "DoubleType":
                        recs.append(StructField(field_item[0], DoubleType(), field["isNullable"]))
                    elif field_item[1] == "UUIDType":
                        recs.append(StructField(field_item[0], StringType(), field["isNullable"]))
                    elif field_item[1] == "BooleanType":
                        recs.append(StructField(field_item[0], BooleanType(), field["isNullable"]))
                fields.append(StructField(fieldName, ArrayType(StructType(recs)), field["isNullable"]))
            else:
                fields.append(StructField(fieldName, StringType(), field["isNullable"]))

            list_of_fields_flat.append(fieldName)

        if field["parent"] is None:
            list_of_fields.append(f'{field["fieldName"]}')
        else:
            list_of_fields.append(f'{field["parent"]}.{field["fieldName"]}')

    schema = StructType(fields)
    return schema, list_of_fields, list_of_fields_flat