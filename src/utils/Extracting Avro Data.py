from avro.datafile import DataFileReader
from avro.io import DatumReader
import sys

def replace_zeros(avro_file_name: str, idx: int):
    scale = "0"*len(str(idx))
    json_file_name = avro_file_name.replace(f"{scale}.avro", f"{idx}.json")
    return json_file_name

def extract_avro_data(avro_file_path: str, avro_file_name: str):
    try: 
        reader = DataFileReader(open(avro_file_path + avro_file_name, "rb"), DatumReader())
        idx = 0
        for record in reader:
            recordStr = str(record).replace("'", '"').replace(": None", ': null')
            # print(recordStr)
            json_file_name = replace_zeros(avro_file_name, idx)
            with open(avro_file_path + json_file_name, 'w') as f:
                f.write(recordStr)
                idx += 1
    except Exception as e:
        print("There was an error with avro reading: " + str(e))
    finally:
        reader.close()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        try:
            avro_file_path = sys.argv[1]
            avro_file_name = sys.argv[2]
        except Exception as e:
            print("There was an error wiht cmd arguments passed: " + str(e))
            exit(1)
    else:
        avro_file_path = "C:\\Data\\YARA 2022-05-03 FFDP\\UBE - Universal Backend\\Kafka\\avro_files\\"
        avro_file_name = "users+0+0000000000.avro"
    extract_avro_data(avro_file_path, avro_file_name)

    print("conversion is completed")