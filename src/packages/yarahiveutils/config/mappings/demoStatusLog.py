demoStatusLog_mapping = {
    "id": "id",
    "demoId": "correlationId",
    "type": "type",
    "payload": {
        "assignedTo":"payload.assignedTo.$oid",
        "comment":"payload.comment",
        "note":"payload.note",
        "prevStatus":"payload.prevStatus",
        "demoId":"payload.demoId.$oid",
    },
    "createdBy": "createdBy.$oid",
    "createdAt": "createdAt.$date",
    "updatedAt": "updatedAt.$date",
    "updatedBy": None,
    "notifiedViaEmailAt": "notifiedViaEmailAt.$date"
}
