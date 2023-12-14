import 'package:flutter/material.dart';
import 'package:my_app/pages/payment_screen.dart';

class SubscriptionsPlans extends StatefulWidget {
  const SubscriptionsPlans({super.key});

  @override
  State<SubscriptionsPlans> createState() => _SubscriptionsPlansState();
}

class _SubscriptionsPlansState extends State<SubscriptionsPlans> {
  int selectedOption = 0;
  List<Plan> plans = [
    Plan(title: 'Basic', plansPrice: '\$ 1/Month', description: [
      " 5 hours  Transcribed Audio summery",
      " Total 10 Minutes Audio Transcriptions.",
      " No Chat bot access.",
    ]),
    Plan(title: "Silver", plansPrice: '\$ 5/Month', description: [
      " Unlimited Transcribed Audio summery",
      " Total 1 hours Audio Transcriptions.",
      " Limited Chat bot access (only 5 questions).",
      " Summarizing Features Enable.",
    ]),
    Plan(title: 'Gold', plansPrice: '\$ 10/Month', description: [
      " Unlimited Transcribed Audio summery",
      " Total 5 hours Audio Transcriptions.",
      "  Chat bot access (50 questions).",
      " Summarizing Features Enable.",
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subscriptions Plans"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromRGBO(235, 236, 236, 1.0),
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: const Color.fromRGBO(235, 236, 236, 1.0),
                child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (BuildContext context, int index) {
                      Plan data = plans[index];
                      return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedOption = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(10),
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: selectedOption == index
                                  ? Colors.blue.shade100
                                  : Colors.white,
                              border: Border.all(
                                  color: selectedOption == index
                                      ? Colors.blue
                                      : Colors.white,
                                  width: 5),
                            ),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        data.title,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                            color: Colors.black87),
                                      ),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.orangeAccent,
                                        size: 20,
                                      )
                                    ],
                                  ),
                                ),
                                buildDescription(data),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: Colors.grey.shade200),
                                    child: Center(
                                      child: Text(
                                        data.plansPrice,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            decoration: TextDecoration.none),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ));
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                color: Colors.blue,
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PaymentScreen(planIndex: selectedOption)));
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  child: Text(
                    "Subscribe",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded buildDescription(Plan data) {
    return Expanded(
        child: Column(
      children: data.description
          .map((description) => Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.star_border,
                    color: Colors.orangeAccent,
                    size: 15,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ))
          .expand((widget) => [widget, const SizedBox(height: 10)])
          .toList(),
    ));
  }
}

class Plan {
  final String title;
  final String plansPrice;
  List<String> description;

  Plan(
      {required this.title,
      required this.plansPrice,
      required this.description});
}
