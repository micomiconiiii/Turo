//Mentee Matching Data Service (Mentor side)
import '../models/mentee_profile.dart';

class MenteeMatchingDataService {
  Future<List<MenteeProfile>> getSuggestedMentees(String mentorId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      MenteeProfile(
        id: 'mentee_mico',
        fullName: 'MICO ABAS',
        joinDate: DateTime.now(),
        profileImageUrl: 'assets/images/mico_abas.png',
        skillsToLearn: ['UI/UX', 'Frontend', 'Backend'],
        bio:
            'I am a student taking up Bachelor of Science in Information Technology',
        targetMentors: ['Software Engineer', 'IT Mentor'],
        budget: 'PHP200/hr',
        goals: ['Career Development', 'Long-term based'],
        notes: 'I am currently looking for a long-term mentorship. hmu!',
        currentRole: 'IT Student',
        status: 'seeking_mentor',
      ),
      MenteeProfile(
        id: 'mentee_jamie',
        fullName: 'JAMIE DABAO',
        joinDate: DateTime.now(),
        profileImageUrl: 'assets/images/jamie_dabao.png',
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
      MenteeProfile(
        id: 'mentee_aeron',
        fullName: 'AERON SINGSON',
        joinDate: DateTime.now(),
        profileImageUrl: 'assets/images/aeron_singson.png',
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
