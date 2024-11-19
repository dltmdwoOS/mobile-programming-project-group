import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/file_service.dart';
import '../service/shared_preferences_service.dart';
import '../widget/home_icon_widget.dart';
import 'result_screen.dart';

class TravelSummaryPage extends StatefulWidget {
  final String planName;
  final String country;
  final String state;
  final String currency;
  final String budget;
  final DateTime departureDate;
  final DateTime arrivalDate;
  final String companion;
  final String style;
  final VoidCallback onPlanAdded;
  TravelSummaryPage({
    required this.planName,
    required this.country,
    required this.state,
    required this.currency,
    required this.budget,
    required this.departureDate,
    required this.arrivalDate,
    required this.companion,
    required this.style,
    required this.onPlanAdded
  });

  @override
  State<TravelSummaryPage> createState() => _TravelSummaryPageState();
}

class _TravelSummaryPageState extends State<TravelSummaryPage> {
  bool _isLoading = false;
  String _response = "";
  Future<bool> processText() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final url = Uri.parse("http://35.239.127.11:8080/process_text");
      List<Map<String, String>> conversation = [
        {
          "role": "system",
          "content": "You are a travel consultant who creates a travel itinerary for users by inputting their destination, period, and budget ... etc. You should respond similarly to the example format below. The recommended plan should be compact, yet full of information and should be as detailed as possible. It should be written in Python dictionary(Map format) form. And you have to write a plan by inserting the recommended food for the day at least once a day. The recommended food is good as long as it shows the characteristics of the country well.",
        },
        {
          "role": "system",
          "content": "When user said 'I'll go to Tokyo, Japan. My budget is 2000 USD. I'll travel for 2024/1/5 ~ 2024/1/7. I'll travel with family. My travel style is Experience·Activity', and then you should respond like: \nCountry : Japan\nState : Tokyo\nCurrency : USD\nBudget : 2000\nDeparture date : 2024/1/5,\nArrival date : 2024/1/7\nTravel companion : With friend\nTravel style : Experience·Activity\nPlan : {\"2024/1/5\" : \"Morning: Visit Meiji Shrine, take a stroll in the beautiful gardens,  Afternoon: Explore the trendy Harajuku district,  Night: Enjoy a traditional Japanese dinner at Shibuya's Nonbei Yokocho\", \"2024/1/6\" : \"Morning: Take a day trip to Nikko, visit the UNESCO World Heritage-listed Toshogu Shrine,  Afternoon: Return to Tokyo and visit the Tokyo Skytree for panoramic views,  Night: Explore the vibrant Shinjuku district, visit the Golden Gai for a unique experience\", \"2024/1/7\" : \"Morning: Visit the Tokyo National Museum, learn about Japan's rich history and culture,  Afternoon: Take a stroll in the Imperial Palace East Garden,  Night: Enjoy a sumo tournament at the Ryogoku Kokugikan (= If the sumo tournament schedule matches with your travel dates) or explore the lively Roppongi district\"}"
        },
        {
          "role": "system",
          "content": "You don't have to comment about total cost, total budget, ... etc. Answer correctly only in the above format."
        },
        {
          "role": "user",
          "content": "I'll go to Hanoi, Vietnam. My budget is 500 USD. I'll travel for 2024/9/21 ~ 2024/9/23. I'll travel alone. My travel style is Relax·Heal"
        },
        {
          "role": "assistant",
          "content": 'Country : Vietnam\nState : Hanoi\nCurrency : USD\nBudget : 500\nDeparture date : 2024/9/21,\nArrival date : 2024/9/23\nTravel companion : Alone\nTravel style : Relax·Heal\nPlan : {\"2024/9/21\" : \"Morning: Explore the tranquility of the Temple of Literature, taste traditional Vietnamese coffee,  Afternoon: Wander around the Old Quarter, visit Dong Xuan Market for some local shopping,  Night: Enjoy a delicious dinner of authentic Vietnamese street food, try Pho or Bun Cha\", \"2024/9/22\" : \"Morning: Take a stroll around Lake Hoan Kiem, visit Ngoc Son Temple,  Afternoon: Treat yourself to a rejuvenating massage at a local spa,  Night: Experience the vibrant night market on Yen Phu Street, try some local snacks and drinks\", \"2024/9/23\" : \"Morning: Visit Ho Chi Minh Mausoleum and explore the Presidential Palace,  Afternoon: Relax at the Botanical Garden,  Night: Enjoy a peaceful evening at Thong Nhat Park, sit back and watch the sunset\"}'
        },
        {
          "role": "user",
          "content": "I'll go to Seoul, Korea South. My budget is 2000 USD. I'll travel for 2024/12/21 ~ 2024/12/26. I'll travel with parents. My travel style is With Famous Travel Attraction"
        },
        {
          "role": "assistant",
          "content": 'Country : South Korea\nState : Seoul\nCurrency : USD\nBudget : 2000\nDeparture date : 2024/12/21,\nArrival date : 2024/12/26\nTravel companion : With parents\nTravel style : With Famous Travel Attraction\nPlan : {"2024/12/21" : "Morning: Explore the iconic Gyeongbokgung Palace, watch the Changing of the Guard ceremony,  Afternoon: Visit the National Folk Museum, learn about Korean culture,  Night: Enjoy a traditional Korean dinner at Myeong-dong\'s food alley, try some street food", "2024/12/22" : "Morning: Visit the Bukchon Hanok Village, stroll through the narrow streets of traditional Korean architecture,  Afternoon: Explore the Namsan Tower (Seoul Tower) for panoramic views of the city,  Night: Experience the vibrant nightlife of Hongdae, visit the Hongdae Free Market for some shopping and food", "2024/12/23" : "Morning: Visit the War Memorial of Korea, learn about the country\'s history and war efforts,  Afternoon: Stop by the Jogyesa Temple, a center for Buddhism in Korea,  Night: Enjoy the spectacular light and fountain show at the Lotte World Mall", "2024/12/24" : "Morning: Visit the Myeong-dong shopping district, shop and dine at one of the busiest streets in Seoul,  Afternoon: Explore the trendy Gangnam district, visit the COEX Mall for some shopping and dining,  Night: Celebrate Christmas at the ice rink of the Seoul Plaza", "2024/12/25" : "Rest day", "2024/12/26" : "Morning: Visit the Seoul Grand Park, explore the zoo, gardens, and lake,  Afternoon: Stop by the National Museum of Korea, learn about Korea\'s art, history, and culture,  Night: Enjoy a farewell dinner at a traditional Korean restaurant"}'
        },
        {
          "role": "user",
          "content": "I'll go to Attica Region, Greece. My budget is 300 USD. I'll travel for 2024/4/11 ~ 2024/4/12. I'll travel with parents. My travel style is Culture·Art·History"
        },
        {
          "role": "assistant",
          "content": 'Country : Greece\nState : Attica Region\nCurrency : USD\nBudget : 300\nDeparture date : 2024/4/11,\nArrival date : 2024/4/12\nTravel companion : With parents\nTravel style : Culture·Art·History\nPlan : {"2024/4/11" : "Morning: Visit the Acropolis of Athens, explore the ancient Parthenon,  Afternoon: Explore the National Archaeological Museum, learn about ancient Greece\'s art and history,  Night: Enjoy a traditional Greek dinner at Plaka, a historic neighborhood in Athens", "2024/4/12" : "Morning: Visit the Ancient Agora, explore the Temple of Hephaestus and the Museum of the Ancient Agora,  Afternoon: Stop by the Monastiraki Flea Market, a popular spot for antiquities and souvenirs,  Night: Watch a traditional Greek dance show at the music hall, end the evening with a folk dance performance"}'
        },
        {
          "role": "user",
          "content": "I'll go to Flanders, Belgium. My budget is 1000 EUR. I'll travel for 2024/6/15 ~ 2024/6/22. I'll travel with friend. My travel style is With nature"
        },
        {
          "role": "assistant",
          "content": 'Country : Belgium\nRegion : Flanders\nCurrency : EUR\nBudget : 1000\nDeparture date : 2024/6/15,\nArrival date : 2024/6/22\nTravel companion : With friend\nTravel style : With nature\nPlan : {"2024/6/15" : "Morning: Explore the beautiful city of Ghent, visit the Ghent Cathedral and the Castle of Ghent,  Afternoon: Take a boat tour along the Leie River,  Night: Enjoy a traditional Belgian dinner and some beers in the city center", "2024/6/16" : "Morning: Visit the Flanders Fields, pay tribute to the soldiers who fought in World War I,  Afternoon: Explore the scenic town of Bruges, visit the Belfry Tower and the Church of Our Lady,  Night: Enjoy a relaxing evening at a cozy bed and breakfast", "2024/6/17" : "Morning: Take a bike tour along the Flemish countryside, ride through picturesque villages and fields,  Afternoon: Visit the Puyenbroek Arboretum, a beautiful park with a wide variety of trees,  Night: Enjoy a picnic dinner at a scenic spot", "2024/6/18" : "Morning: Visit the Kemmelberg, a hill with a beautiful view over the surrounding countryside,  Afternoon: Explore the charming town of Kortrijk, visit the Kortrijk Grote Markt and the Kortrijk Museum,  Night: Enjoy a dinner at a local trattoria", "2024/6/19" : "Morning: Visit the De Haan Nature Reserve, explore the forests and dunes along the North Sea Coast,  Afternoon: Take a scenic coastal walk along the beach,  Night: Enjoy a seafood dinner at a restaurant in Ostend", "2024/6/20" : "Morning: Visit the Oostduinkerke Beach, see the impressive sand dunes and the horse-riding dune sliders,  Afternoon: Explore the town of De Panne, visit the De Panne Abbey and the De Panne Museum,  Night: Enjoy a dinner and some live music at a local bar", "2024/6/21" : "Morning: Take a day trip to the Netherlands, visit the city of Brussel,  Afternoon: Explore the Atomium and the Europa Building,  Night: Enjoy a dinner at a rooftop restaurant with a view of the city", "2024/6/22" : "Morning: Visit the Egmontpark, a beautiful park with a zoological and botanical garden,  Afternoon: Explore the historic city center of Ghent, visit the St. Bavo\'s Cathedral,  Night: Enjoy a farewell dinner at a Michelin-starred restaurant"}'
        },
        {
          "role": "user",
          "content": "I'll go to , Greenland. My budget is 400 USD. I'll travel for 2024/11/3 ~ 2024/11/5. I'll travel alone. My travel style is With nature"
        },
        {
          "role": "assistant",
          "content": 'Country : Greenland\nCurrency : USD\nBudget : 400\nDeparture date : 2024/11/3,\nArrival date : 2024/11/5\nTravel companion : Alone\nTravel style : With nature\nPlan : {"2024/11/3" : "Morning: Arrive in Nuuk, the capital of Greenland, and check-in at a cozy guesthouse,  Afternoon: Explore the beautiful botanical garden, Nuuk Botanik Have, and visit the National Museum of Greenland,  Night: Enjoy a traditional Greenlandic dinner at a local restaurant", "2024/11/4" : "Morning: Take a day trip to the nearby Nuuk Fjord, enjoy a scenic boat tour and see the stunning glaciers and sea ice,  Afternoon: Return to Nuuk and explore the city\'s charming old town,  Night: Enjoy a relaxing evening at your guesthouse", "2024/11/5" : "Morning: Visit the Nuuk Zoo, home to many Arctic animals, including musk oxen and reindeer,  Afternoon: Take a short hike to the nearby Nuuk Waterfall, a picturesque spot with a stunning view,  Night: Depart from Nuuk"}'
        },
        {
          "role": "user",
          "content": "I'll go ${widget.country}, ${widget.state}. My budget is ${widget.budget} ${widget.currency}. I'll travel for ${widget.departureDate.toLocal().year}/${widget.departureDate.toLocal().month}/${widget.departureDate.toLocal().day} ~ ${widget.arrivalDate.toLocal().year}/${widget.arrivalDate.toLocal().month}/${widget.arrivalDate.toLocal().day}. I'll travel ${widget.companion}. My travel style is ${widget.style}."
        }

      ];
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(conversation),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await saveJsonToFile(responseData, "outputs/${widget.planName}.txt");
        setState(() {
          _response = "Data saved successfully!";
        });
        return true;
      } else {
        setState(() {
          _response = "Error: ${response.statusCode}, ${response.reasonPhrase}";
        });
        return false;
      }
    } catch (e) {
      setState(() {
        _response = "Failed to process text: $e";
      });
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Text('Travel Summary'),
          Expanded(child: Container()),
          HomeIconWidget(hasQuestion: true),
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              title: Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: Center(
                  child: Text(
                    'Selected Travel Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              children: [
                Column(
                  children: [
                    Text('Country: ${widget.country}'),
                    Text('State: ${widget.state}'),
                    Text('Currency: ${widget.currency}'),
                    Text('Budget: ${widget.budget}'),
                    Text('Departure date: ${widget.departureDate.toLocal().year}/${widget.departureDate.toLocal().month}/${widget.departureDate.toLocal().day}'),
                    Text('Arrival date: ${widget.arrivalDate.toLocal().year}/${widget.arrivalDate.toLocal().month}/${widget.arrivalDate.toLocal().day}'),
                    Text('Travel companion: ${widget.companion}'),
                    Text('Travel style: ${widget.style}'),
                  ],
                )
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                List<String> planNames = await SharedPrefUtil.getPlanNames();
                bool success = false;
                if (planNames.contains(widget.planName)){
                  success = true;
                }
                else{
                  planNames.add(widget.planName);
                  await SharedPrefUtil.savePlanNames(planNames);
                  widget.onPlanAdded();
                  success = await processText();
                }
                if (success){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                          planName: widget.planName
                      ),
                    ),
                  );
                }
              },
              child: Text('Complete'),
            ),
          ],
        ),
      ),
    );
  }
}