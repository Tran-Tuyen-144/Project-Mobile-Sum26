import 'package:flutter/material.dart';

class BookingPetScreen extends StatefulWidget {
  final String petName;

  const BookingPetScreen({super.key, required this.petName});

  @override
  State<BookingPetScreen> createState() => _BookingPetScreenState();
}

class _BookingPetScreenState extends State<BookingPetScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController tableController = TextEditingController();

  final TextEditingController hourController = TextEditingController();

  @override
  void dispose() {
    tableController.dispose();
    hourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đặt bàn")),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              Text(
                "Đặt bàn với ${widget.petName}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: tableController,
                decoration: const InputDecoration(
                  labelText: "Số bàn",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập số bàn";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: hourController,
                decoration: const InputDecoration(
                  labelText: "Giờ đặt",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Hủy"),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đặt bàn thành công")),
                          );

                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Xác nhận"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
