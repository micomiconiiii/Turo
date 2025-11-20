// Mentorr Matching Data Service (Mentee side)
import '../models/mentor_profile.dart';

class MenteeMatchingDataService {
  Future<List<MentorProfile>> getSuggestedMatches(String userId) async {
    await Future.delayed(const Duration(milliseconds: 350));

    return [
      const MentorProfile(
        id: 'mentor_001',
        name: 'ALENE BONDOC',
        age: 21,
        isVerified: true,
        rating: '4.5/5',
        tagline: 'UI/UX | Frontend | Backend',
        about:
            'I am an experienced Software Engineer. Swipe right if you want me to be your mentor!',
        expertise: ['UI/UX', 'Frontend', 'Backend'],
        profileImageUrl: 'assets/images/alene_bondoc.png',
        lookingFor: ['Startup Business', 'Student'],
        budget: 'PHP 200/hr',
        goals: ['Career Development', 'Long-term based'],
        notes: 'I am currently looking for a long-term mentorship.',
      ),
      const MentorProfile(
        id: 'mentor_002',
        name: 'ANDREA DUCOSIN',
        age: 22,
        isVerified: true,
        rating: '4/5',
        tagline: 'Product Designer | Figma Expert',
        about:
            'A passionate designer who mentors students in product thinking and prototyping.',
        expertise: ['Product Design', 'Figma', 'Mentorship'],
        profileImageUrl: 'assets/images/andrea_ducosin.png',
        lookingFor: ['Design Mentee', 'Junior UI Designer'],
        budget: 'PHP 175/hr',
        goals: ['Skill Growth', 'Portfolio Review'],
        notes: 'Available on weekends for mentorship.',
      ),
    ];
  }
}
