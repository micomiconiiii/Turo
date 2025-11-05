import '../models/mentor_profile.dart';

/// Simulated data service for mentor suggestions
class MatchingDataService {
  Future<List<MentorProfile>> getSuggestedMatches(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const MentorProfile(
        id: 'mico_abas',
        name: 'MICO ABAS',
        tagline: 'UI/UX | Frontend | Backend',
        about:
            'I am a student taking up Bachelor of Science in Information Technology.',
        expertise: ['UI/UX', 'Frontend', 'Backend', 'Chapter Lead'],
        profileImageUrl: 'assets/images/mico_abas.png',
        lookingFor: ['Software Engineer', 'IT Mentor'],
        budget: 'PHP200/hr',
        goals: ['Career Development', 'Long-term based'],
        notes: 'I am currently looking for a long-term mentorship. Hmu!',
      ),
      const MentorProfile(
        id: 'alyssa_lee',
        name: 'ALYSSA LEE',
        tagline: 'Product Designer | Figma Expert',
        about:
            'A passionate designer who mentors students in product thinking and prototyping.',
        expertise: ['Product Design', 'Figma', 'Mentorship'],
        profileImageUrl:
            'https://placehold.co/400x400/004488/ffffff?text=Alyssa+Lee',
        lookingFor: ['Design Mentee', 'Junior UI Designer'],
        budget: 'PHP250/hr',
        goals: ['Skill Growth', 'Portfolio Review'],
        notes:
            'Open for design consultations and mentoring sessions every weekend!',
      ),
    ];
  }
}
