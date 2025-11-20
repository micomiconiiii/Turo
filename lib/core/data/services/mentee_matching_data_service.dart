import '../models/mentee_profile.dart';

class MenteeMatchingDataService {
  Future<List<MenteeProfile>> getSuggestedMentees(String mentorId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      // --- 1. MICO ABAS (Matches your Screenshot) ---
      MenteeProfile(
        id: 'mentee_mico',
        fullName: 'MICO ABAS',
        joinDate: DateTime.now(),
        // Use a local asset or a URL. If using asset, make sure it exists in pubspec.yaml
        profileImageUrl: 'assets/images/mico_abas.png',

        // The Image Overlay Tags
        skillsToLearn: ['UI/UX', 'Frontend', 'Backend'],

        // "About"
        bio:
            'I am a student taking up Bachelor of Science in Information Technology',

        // "I'm looking for"
        targetMentors: ['Software Engineer', 'IT Mentor'],

        // "My budget is"
        budget: 'PHP200/hr',

        // "Goals"
        goals: ['Career Development', 'Long-term based'],

        // "Notes"
        notes: 'I am currently looking for a long-term mentorship. hmu!',

        currentRole: 'IT Student',
        status: 'seeking_mentor',
      ),

      // --- 2. JAMIE (Dummy Data) ---
      MenteeProfile(
        id: 'mentee_jamie',
        fullName: 'JAMIE DABAO',
        joinDate: DateTime.now(),
        profileImageUrl:
            'assets/images/jamie_dabao.png', // Ensure this exists or use URL
        skillsToLearn: ['Figma', 'Prototyping'],
        bio:
            'Aspiring designer looking to build a strong portfolio for my first job.',
        targetMentors: ['Product Designer', 'UI Lead'],
        budget: 'PHP150/hr',
        goals: ['Portfolio Review', 'Design Systems'],
        notes: 'Available mostly on weekends for calls.',
        currentRole: 'Design Student',
        status: 'seeking_mentor',
      ),

      // --- 3. AERON (Dummy Data) ---
      MenteeProfile(
        id: 'mentee_aeron',
        fullName: 'AERON SINGSON',
        joinDate: DateTime.now(),
        profileImageUrl:
            'assets/images/aeron_singson.png', // Ensure this exists or use URL
        skillsToLearn: ['Python', 'SQL', 'Data Science'],
        bio:
            'Switching careers from marketing to data analytics. Need guidance on the roadmap.',
        targetMentors: ['Data Analyst', 'Data Scientist'],
        budget: 'PHP250/hr',
        goals: ['Technical Interview Prep', 'Python Basics'],
        notes: 'I prefer evening sessions after work hours.',
        currentRole: 'Career Shifter',
        status: 'seeking_mentor',
      ),
    ];
  }
}
