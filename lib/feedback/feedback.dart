import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackUIState createState() => _FeedbackUIState();
}

class _FeedbackUIState extends State<FeedbackScreen> {
  double _rating = 0.0;
  String _feedbackText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text(
          'Feedback',
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), ),
        ),
        centerTitle: true,
         backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Text(
              'Rate your experience (tap to select):',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StarRating(
                  rating: _rating,
                  onRatingChanged: (newRating) {
                    setState(() {
                      _rating = newRating;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
            TextField(
              decoration: InputDecoration(
                hintText: 'Share your thoughts (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              maxLines: null, // Allow multi-line input
              onChanged: (text) {
                setState(() {
                  _feedbackText = text;
                });
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Handle feedback submission logic here
                // (e.g., send to a server, store locally)
                submitFeedback();
              },
              child: Text(
                'Submit Feedback',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
void submitFeedback() async {
  final database = FirebaseDatabase.instance.reference().child("feedback");
  final feedback = {
    "rating": _rating,
    "text": _feedbackText,
  };

  try {
    await database.push().set(feedback);

    // Reset rating and feedback text
    setState(() {
      _rating = 0; // Set to your default value
      _feedbackText = ""; // Set to your default value
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your feedback!'),
      ),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred: $error'),

      ),

    );
    print('Error submitting feedback: $error');
  }
}
}


// Custom StarRating widget for a more visually appealing experience
class StarRating extends StatelessWidget {
  final double rating;
  final Function(double) onRatingChanged;

  const StarRating({required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) => buildStar(index)),
    );
  }

  Widget buildStar(int index) {
    final isStarred = index < rating;
    final color = isStarred ? Color.fromARGB(255, 255, 217, 0) : Colors.grey;
    return IconButton(
      icon: Icon(
        Icons.star,
        size: 30.0,
        color: color,
      ),
      onPressed: () => onRatingChanged(index + 1.0),
    );
  }

  
}

