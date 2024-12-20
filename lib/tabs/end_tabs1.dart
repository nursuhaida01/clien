import 'package:flutter/material.dart';


class ClassEndTabs1 {
  static const List<Map<String, dynamic>> reasons = [
    {'reason_id': 0, 'reason_note': 'พักคิว\nHold'},
    {
      'reason_id': 3,
      'reason_note': 'ยกเลิก:ไม่รอ(คืนคิว)\n Cancel : Return Queue'
    },
    {'reason_id': 4, 'reason_note': 'ยกเลิก : ไม่กลับมา\n Cancel : Absent'},
    {
      'reason_id': 5,
      'reason_note': 'ยกเลิก : ออกคิวผิด\n Cancel : Wrong Queue'
    },
    {'reason_id': '', 'reason_note': 'ปิดหน้าต่าง\n Close'},
  ];

  static Future<void> updateQueueAndNavigate(BuildContext context,
      List<Map<String, dynamic>> T2OK, int reasonId, String reasonNote) async {
    var ReasonNote = (reasonId == 1) ? 'Finishing' : 'Ending';

    // อัพเดตสถานะของคิว
   
  }

  static Future<void> showReasonDialog(
      BuildContext context, List<Map<String, dynamic>> T2OK) async {
    bool _isLoading = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                padding: const EdgeInsets.all(3.0),
                width: screenWidth * 0.8,
                height: screenHeight * 0.6,
                child: Column(
                  children: [
                    Text(
                      "Queue Number : ${T2OK.isNotEmpty ? T2OK.first['queue_no'] ?? 'N/A' : 'No Data'}",
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(9, 159, 175, 1.0),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: ListView.builder(
                        itemCount: reasons.length,
                        itemBuilder: (context, index) {
                          return _isLoading
                              ? const Center(
                                  // child: CircularProgressIndicator(),
                                  )
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      try {
                                        if (reasons[index]['reason_id'] == 1 ||
                                            reasons[index]['reason_id'] == '') {
                                        } else if (reasons[index]
                                                ['reason_id'] ==
                                            0) {
                                         
                                        } else {
                                          await updateQueueAndNavigate(
                                            context,
                                            T2OK,
                                            reasons[index]['reason_id'],
                                            reasons[index]['reason_note'] ?? '',
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('เกิดข้อผิดพลาด: $e'),
                                          ),
                                        );
                                      } finally {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: reasons[index]
                                                  ['reason_id'] ==
                                              ''
                                          ? const Color.fromARGB(255, 255, 0, 0)
                                          : reasons[index]['reason_id'] == 0
                                              ? const Color.fromARGB(
                                                  255, 24, 177, 4)
                                              : const Color.fromARGB(
                                                  255, 219, 118, 2),
                                      minimumSize: Size(screenWidth * 0.8,
                                          screenHeight * 0.09),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                    ),
                                    child: Text(
                                      reasons[index]['reason_note'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
