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
          "content": "This is something you absolutely must keep in mind. When creating a planning dictionary, you absolutely must adhere to the date. For example, if the period is 2024/11/22~2024/12/4, you must print out the entire 13-day plan."
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
          "content": "I'll go to , Greenland. My budget is 400 USD. I'll travel for 2024/11/3 ~ 2024/11/5. I'll travel alone. My travel style is With nature"
        },
        {
          "role": "assistant",
          "content": 'Country : Greenland\nCurrency : USD\nBudget : 400\nDeparture date : 2024/11/3,\nArrival date : 2024/11/5\nTravel companion : Alone\nTravel style : With nature\nPlan : {"2024/11/3" : "Morning: Arrive in Nuuk, the capital of Greenland, and check-in at a cozy guesthouse,  Afternoon: Explore the beautiful botanical garden, Nuuk Botanik Have, and visit the National Museum of Greenland,  Night: Enjoy a traditional Greenlandic dinner at a local restaurant", "2024/11/4" : "Morning: Take a day trip to the nearby Nuuk Fjord, enjoy a scenic boat tour and see the stunning glaciers and sea ice,  Afternoon: Return to Nuuk and explore the city\'s charming old town,  Night: Enjoy a relaxing evening at your guesthouse", "2024/11/5" : "Morning: Visit the Nuuk Zoo, home to many Arctic animals, including musk oxen and reindeer,  Afternoon: Take a short hike to the nearby Nuuk Waterfall, a picturesque spot with a stunning view,  Night: Depart from Nuuk"}'
        },
        {
          "role": "user",
          "content": "I'll go to Cairo, Egypt. My budget is 700 USD. I'll travel for 2024/5/1 ~ 2024/5/3. I'll travel with a friend. My travel style is Culture·Art·History"
        },
        {
          "role": "assistant",
          "content": 'Country : Egypt\nState : Cairo\nCurrency : USD\nBudget : 2000\nDeparture date : 2024/11/15,\nArrival date : 2024/12/7\nTravel companion : With friend\nTravel style : Culture·Art·History\nPlan : {"2024/11/15" : "Morning: Arrive in Cairo and settle into your accommodation, Afternoon: Take a short walk around your neighborhood to familiarize yourself with the area, Night: Enjoy a welcome dinner at a traditional Egyptian restaurant, trying dishes like Koshari or Mulukhiyah", "2024/11/16" : "Morning: Visit the Great Pyramids of Giza and the Sphinx, take plenty of photos and marvel at the ancient wonders, Afternoon: Explore the Solar Boat Museum and learn about ancient Egyptian funerary practices, Night: Watch the Sound and Light Show at the Pyramids, a mesmerizing experience", "2024/11/17" : "Morning: Tour the Egyptian Museum to admire artifacts, including treasures from King Tutankhamun\'s tomb, Afternoon: Walk through Tahrir Square and learn about modern Egyptian history, Night: Enjoy a traditional dinner with live music in downtown Cairo", "2024/11/18" : "Morning: Visit the Hanging Church and other sites in Coptic Cairo to explore Egypt\'s Christian heritage, Afternoon: Explore the Gayer-Anderson Museum, an architectural gem showcasing Islamic art, Night: Relax with a traditional Egyptian tea at a local cafe", "2024/11/19" : "Morning: Take a day trip to Saqqara to see the Step Pyramid and the ancient tombs, Afternoon: Visit the Dahshur pyramids, including the Bent Pyramid and the Red Pyramid, Night: Return to Cairo and enjoy a relaxed evening", "2024/11/20" : "Morning: Explore Islamic Cairo, starting with the Citadel of Saladin and the Mosque of Muhammad Ali, Afternoon: Visit Al-Muizz Street and Khan El Khalili Bazaar for some shopping and sightseeing, Night: Have dinner at a rooftop restaurant with views of the city", "2024/11/21" : "Morning: Take a Nile River cruise to Aswan (overnight), enjoy the scenic views along the way, Afternoon: Relax on the boat and enjoy the onboard activities, Night: Relish a luxurious dinner while gliding along the Nile", "2024/11/22" : "Morning: Arrive in Aswan and visit the Aswan High Dam and the Unfinished Obelisk, Afternoon: Tour the Philae Temple, dedicated to the goddess Isis, Night: Stay in a charming hotel and enjoy Nubian cuisine for dinner", "2024/11/23" : "Morning: Take a boat trip to Abu Simbel, marvel at the colossal temples of Ramses II, Afternoon: Return to Aswan and explore the Nubian Museum to learn about the region\'s history, Night: Enjoy a relaxing evening along the Nile promenade", "2024/11/24" : "Morning: Depart for Luxor, known as the world\'s greatest open-air museum, Afternoon: Visit the Luxor Temple and stroll along the Avenue of Sphinxes, Night: Dine at a riverside restaurant in Luxor", "2024/11/25" : "Morning: Explore the Karnak Temple complex, one of the most impressive ancient sites, Afternoon: Take a felucca ride on the Nile and enjoy the serene atmosphere, Night: Attend the Sound and Light Show at Karnak Temple", "2024/11/26" : "Morning: Cross the Nile to the West Bank and visit the Valley of the Kings, including Tutankhamun\'s tomb, Afternoon: Explore the Temple of Hatshepsut and the Colossi of Memnon, Night: Relax with a dinner in a traditional Luxor setting", "2024/11/27" : "Morning: Take a hot air balloon ride over Luxor for breathtaking views, Afternoon: Visit the Luxor Museum to see its impressive collection, Night: Enjoy a quiet evening at your hotel or stroll along the Nile", "2024/11/28" : "Morning: Travel back to Cairo by train or flight, Afternoon: Relax and recover from your journey, Night: Enjoy dinner at a modern Egyptian restaurant with fusion cuisine", "2024/11/29" : "Morning: Visit the Agricultural Museum to explore Egypt\'s farming heritage, Afternoon: Tour the Manial Palace for its beautiful architecture and gardens, Night: Attend a cultural performance at the Cairo Opera House", "2024/11/30" : "Morning: Take a day trip to Fayoum, visit the Wadi El Rayan waterfalls and the Valley of the Whales (UNESCO World Heritage Site), Afternoon: Explore the pottery workshops in Tunis Village, Night: Return to Cairo and enjoy a late dinner", "2024/12/1" : "Morning: Explore modern Cairo with a visit to the Baron Empain Palace, Afternoon: Tour the bustling markets of Souq El Gomaa, Night: Enjoy a peaceful dinner in Zamalek, a trendy district", "2024/12/2" : "Morning: Visit the Museum of Islamic Art for its exquisite collection, Afternoon: Explore the Al-Azhar Park, a green oasis with panoramic views of Cairo, Night: Have dinner at a restaurant overlooking the park", "2024/12/3" : "Morning: Tour the Mokattam Hills and the Cave Church, Afternoon: Visit Garbage City to learn about its recycling efforts and community, Night: Attend a traditional Sufi dance show at Wekalet El Ghouri", "2024/12/4" : "Morning: Explore the northern area of Cairo with a visit to the Shubra Palace, Afternoon: Visit the Agricultural Land Museum for a different perspective on Egypt\'s history, Night: Relax with an evening of Egyptian cinema at a local theater", "2024/12/5" : "Morning: Visit Al-Fayoum Oasis for its natural beauty, Afternoon: Stop by the ancient ruins of Karanis, Night: Return to Cairo and have a dinner of Egyptian desserts at a famous patisserie", "2024/12/6" : "Morning: Take a private cooking class to learn traditional Egyptian recipes, Afternoon: Visit the Cairo Tower for panoramic views of the city, Night: Celebrate your last evening with a dinner cruise on the Nile", "2024/12/7" : "Morning: Do some last-minute souvenir shopping in Cairo, Afternoon: Relax and prepare for departure, Night: Depart Cairo with wonderful memories of your trip"}'
        },
        {
          "role": "user",
          "content": "I'll go ${widget.country}, ${widget.state}. My budget is ${widget.budget} ${widget.currency}. I'll travel for ${widget.departureDate.toLocal().year}/${widget.departureDate.toLocal().month}/${widget.departureDate.toLocal().day} ~ ${widget.arrivalDate.toLocal().year}/${widget.arrivalDate.toLocal().month}/${widget.arrivalDate.toLocal().day}. I'll travel ${widget.companion}. My travel style is ${widget.style}."
        },
      ];
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(conversation),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await saveJsonToFile(responseData, "outputs/${widget.planName}.txt");
        setState(() {
          _response = "Data saved successfully!";
        });
        print(_response);
        return true;
      } else {
        setState(() {
          _response = "Error: ${response.statusCode}, ${response.reasonPhrase}";
        });
        print(_response);
        return false;
      }
    } catch (e) {
      setState(() {
        _response = "Failed to process text: $e";
      });
      print(_response);
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

                while(!success){
                  if (!planNames.contains(widget.planName)){
                    planNames.add(widget.planName);
                  }
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