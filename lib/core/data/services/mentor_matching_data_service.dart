import '../models/mentor_profile.dart';

/// Simulated data service for mentor suggestions
class MatchingDataService {
  Future<List<MentorProfile>> getSuggestedMatches(String userId) async {
    // Simulate a network delay
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
        id: 'jamie_dabao',
        name: 'JAMIE DABAO',
        tagline: 'Product Designer | Figma Expert',
        about:
            'A passionate designer who mentors students in product thinking and prototyping.',
        expertise: ['Product Design', 'Figma', 'Mentorship'],
        profileImageUrl: 'assets/images/jamie_dabao.png',
        lookingFor: ['Design Mentee', 'Junior UI Designer'],
        budget: 'PHP175/hr',
        goals: ['Skill Growth', 'Portfolio Review'],
        notes:
            'Open for design consultations and mentoring sessions every weekend!',
      ),
      const MentorProfile(
        id: 'aeron_singson',
        name: 'AERON SINGSON',
        tagline: 'Data Analyst | Software Developer | SQL & Python Expert',
        about:
            'Experienced in building data pipelines and developing full-stack applications. Passionate about turning raw data into actionable insights.',
        expertise: [
          'Data Analysis',
          'Python',
          'SQL',
          'Full-Stack Development',
          'Cloud Computing'
        ],
        profileImageUrl: 'assets/images/aeron_singson.png',
        lookingFor: ['Junior Developer', 'Data Science Aspirant'],
        budget: 'PHP250/hr',
        goals: ['Career Guidance', 'Code Review', 'Project Strategy'],
        notes:
            'Available for mentorship focused on technical interviews and real-world project development, primarily Mon-Wed evenings.',
      ),
      // ----------------------------------------
    ];
  }
}
