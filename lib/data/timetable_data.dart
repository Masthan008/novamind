class TimetableData {
  
  // 🔑 Helper to get schedule safely
  static Map<String, List<String>> getSchedule(String branch, String section) {
    // 1. Normalize Keys (Remove spaces, uppercase)
    // Example: Branch "CSE (AI&ML)" becomes "CSE-AIML"
    String normalizedBranch = branch.trim().toUpperCase()
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(' ', '-')
        .replaceAll('&', '');
    
    String key = "${normalizedBranch}_${section.trim().toUpperCase()}";
    
    // 2. Return Data
    return allSchedules[key] ?? _emptySchedule;
  }

  // 🕐 Period Timings (Official from RGMCET - Updated Feb 2026)
  static const Map<String, String> periodTimings = {
    'Period 1': '9:00 AM - 10:40 AM',
    'Break': '10:40 AM - 11:00 AM',
    'Period 2': '11:00 AM - 11:50 AM',
    'Lunch': '11:50 AM - 1:00 PM',
    'Period 3': '1:00 PM - 1:50 PM',
    'Period 4': '1:50 PM - 2:40 PM',
    'Period 5': '3:00 PM - 5:00 PM (Lab/Self-Study)',
  };

  // 📚 Subject Full Names (Updated Feb 2026)
  static const Map<String, String> subjectNames = {
    // Common Subjects
    'CHE': 'Chemistry',
    'CHE LAB': 'Chemistry Lab',
    'CE': 'Communicative English',
    'CE LAB': 'Communicative English Lab',
    'BCE': 'Basic Civil Engineering',
    'BME': 'Basic Mechanical Engineering',
    'EWS': 'Engineering Workshop',
    'EAA': 'Health & Wellness, Yoga and Sports',
    'SS': 'Soft Skills',
    
    // Programming & CS Subjects
    'DEVC': 'Development in C',
    'DS': 'Data Structures',
    'DS LAB': 'Data Structures Lab',
    'ITWS': 'IT Workshop',
    
    // Electronics & Electrical
    'NWA': 'Network Analysis',
    'NWA LAB': 'Network Analysis Lab',
    'ECA': 'Electronic Circuit Analysis',
    'ECA LAB': 'Electronic Circuit Analysis Lab',
    'NWA/ECA': 'Network Analysis / Electronic Circuit Analysis',
    'NWA/ECA LAB': 'Network Analysis / Electronic Circuit Analysis Lab',
    'BEE A': 'Basic Electrical Engineering - A',
    'BEE B': 'Basic Electrical Engineering - B',
    'EEEW LAB': 'Electrical & Electronics Engineering Workshop',
    
    // Physics & Graphics
    'EP': 'Engineering Physics',
    'EP LAB': 'Engineering Physics Lab',
    'EG': 'Engineering Graphics',
    
    // Mechanical
    'EM': 'Engineering Mechanics',
    'EM LAB': 'Engineering Mechanics Lab',
  };

  static final Map<String, List<String>> _emptySchedule = {
    'Monday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
    'Tuesday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
    'Wednesday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
    'Thursday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
    'Friday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
    'Saturday': ['No Data', 'Contact Admin', 'Free', 'Free', 'Free'],
  };

  // 🗓️ THE MASTER DATABASE (Feb 2026 - R23 Regulation)
  // WEF: 05.02.2026 | Coordinator: Dr. P. Sudarsan Reddy
  static final Map<String, Map<String, List<String>>> allSchedules = {

    // ================= ECE SECTIONS =================
    'ECE_A': {
      'Monday': ['CHE', 'CE', 'DEVC', 'Free', 'NWA LAB'],
      'Tuesday': ['Free', 'CHE LAB', 'Free', 'BME', 'CE'],
      'Wednesday': ['DEVC', 'CHE', 'NWA', 'Free', 'EWS'],
      'Thursday': ['NWA', 'BME', 'SS', 'Free', 'BCE'],
      'Friday': ['Free', 'CE LAB', 'BCE', 'CE', 'CHE'],
      'Saturday': ['DEVC', 'CE', 'Free', 'NWA', 'EAA'],
    },
    'ECE_B': {
      'Monday': ['SS', 'CE', 'DEVC', 'EWS', 'Free'],
      'Tuesday': ['BCE', 'CHE', 'DEVC', 'NWA', 'Free'],
      'Wednesday': ['CHE', 'CE', 'BME', 'NWA LAB', 'Free'],
      'Thursday': ['CHE LAB', 'NWA', 'EAA', 'Free', 'Free'],
      'Friday': ['CE', 'BCE', 'NWA', 'CE LAB', 'Free'],
      'Saturday': ['DEVC', 'CE', 'BME', 'CHE', 'Free'],
    },
    'ECE_C': {
      'Monday': ['CE', 'BME', 'DEVC', 'NWA', 'Free'],
      'Tuesday': ['DEVC', 'NWA', 'CE', 'NWA LAB', 'Free'],
      'Wednesday': ['CHE', 'SS', 'CE', 'BCE', 'Free'],
      'Thursday': ['CE LAB', 'NWA', 'DEVC', 'BME', 'Free'],
      'Friday': ['DEVC', 'BME', 'EWS', 'Free', 'CHE'],
      'Saturday': ['CHE LAB', 'BCE', 'CHE', 'EAA', 'Free'],
    },
    // ECE-D and EEE-B share the same timetable
    'ECE_D': {
      'Monday': ['CHE', 'BCE', 'CE', 'BME', 'Free'],
      'Tuesday': ['SS', 'NWA/ECA', 'DEVC', 'Free', 'CHE LAB'],
      'Wednesday': ['DEVC', 'CHE', 'BCE', 'Free', 'CE'],
      'Thursday': ['EWS', 'Free', 'NWA/ECA', 'Free', 'EAA'],
      'Friday': ['DEVC', 'BME', 'CHE', 'Free', 'NWA/ECA LAB'],
      'Saturday': ['NWA/ECA', 'CHE', 'CE', 'Free', 'CE LAB'],
    },

    // ================= EEE SECTIONS =================
    'EEE_A': {
      'Monday': ['DEVC', 'CE', 'ECA', 'Free', 'CHE LAB'],
      'Tuesday': ['ECA', 'BCE', 'CHE', 'Free', 'EWS'],
      'Wednesday': ['CE', 'DEVC', 'BME', 'Free', 'ECA LAB'],
      'Thursday': ['SS', 'ECA', 'CE', 'Free', 'CE LAB'],
      'Friday': ['BCE', 'CE', 'Free', 'CHE', 'DEVC'],
      'Saturday': ['BME', 'ECA', 'Free', 'CHE', 'EAA'],
    },
    // EEE-B shares timetable with ECE-D
    'EEE_B': {
      'Monday': ['CHE', 'BCE', 'CE', 'BME', 'Free'],
      'Tuesday': ['SS', 'NWA/ECA', 'DEVC', 'Free', 'CHE LAB'],
      'Wednesday': ['DEVC', 'CHE', 'BCE', 'Free', 'CE'],
      'Thursday': ['EWS', 'Free', 'NWA/ECA', 'Free', 'EAA'],
      'Friday': ['DEVC', 'BME', 'CHE', 'Free', 'NWA/ECA LAB'],
      'Saturday': ['NWA/ECA', 'CHE', 'CE', 'Free', 'CE LAB'],
    },

    // ================= ME SECTIONS =================
    'ME_A': {
      'Monday': ['CE LAB', 'Free', 'Free', 'BME', 'SS'],
      'Tuesday': ['CE', 'BME', 'EM', 'Free', 'EM LAB'],
      'Wednesday': ['DEVC', 'BCE', 'CHE', 'Free', 'EM'],
      'Thursday': ['CHE', 'DEVC', 'Free', 'BCE', 'CE'],
      'Friday': ['EWS', 'Free', 'Free', 'EM', 'EAA'],
      'Saturday': ['DEVC', 'CE', 'CHE', 'Free', 'CHE LAB'],
    },
    // ME-B shares timetable with CIVIL
    'ME_B': {
      'Monday': ['BCE', 'EM', 'CE', 'Free', 'CHE LAB'],
      'Tuesday': ['EM', 'BCE', 'DEVC', 'Free', 'CE LAB'],
      'Wednesday': ['CHE', 'EWS', 'DEVC', 'Free', 'EM LAB'],
      'Thursday': ['SS', 'EM', 'BME', 'Free', 'EAA'],
      'Friday': ['DEVC', 'EM', 'CHE', 'Free', 'CE'],
      'Saturday': ['CE', 'EM', 'BME', 'Free', 'CHE'],
    },

    // ================= CIVIL SECTION =================
    'CIVIL_A': {
      'Monday': ['BCE', 'EM', 'CE', 'Free', 'CHE LAB'],
      'Tuesday': ['EM', 'BCE', 'DEVC', 'Free', 'CE LAB'],
      'Wednesday': ['CHE', 'EWS', 'DEVC', 'Free', 'EM LAB'],
      'Thursday': ['SS', 'EM', 'BME', 'Free', 'EAA'],
      'Friday': ['DEVC', 'EM', 'CHE', 'Free', 'CE'],
      'Saturday': ['CE', 'EM', 'BME', 'Free', 'CHE'],
    },

    // ================= CSE (AI&ML) SECTIONS =================
    'CSE-AIML_A': {
      'Monday': ['DEVC', 'CE', 'Free', 'BCE', 'DS'],
      'Tuesday': ['EWS', 'Free', 'Free', 'CE', 'CHE'],
      'Wednesday': ['DEVC', 'CHE', 'Free', 'DS LAB', 'BME'],
      'Thursday': ['DS', 'BCE', 'DEVC', 'Free', 'CHE LAB'],
      'Friday': ['BME', 'CHE', 'Free', 'DS LAB', 'CE'],
      'Saturday': ['CE LAB', 'Free', 'Free', 'SS', 'EAA'],
    },
    'CSE-AIML_B': {
      'Monday': ['DS', 'BME', 'CHE', 'Free', 'CE LAB'],
      'Tuesday': ['CHE', 'DEVC', 'DS LAB', 'Free', 'BCE'],
      'Wednesday': ['CHE LAB', 'Free', 'Free', 'CE', 'DS'],
      'Thursday': ['DEVC', 'CE', 'DS LAB', 'Free', 'CHE'],
      'Friday': ['CE', 'BCE', 'BME', 'Free', 'EAA'],
      'Saturday': ['EWS', 'Free', 'Free', 'DEVC', 'SS'],
    },
    'CSE-AIML_C': {
      'Monday': ['CHE LAB', 'Free', 'Free', 'CE', 'DEVC'],
      'Tuesday': ['BCE', 'BME', 'SS', 'Free', 'DS LAB'],
      'Wednesday': ['CE LAB', 'Free', 'Free', 'CHE', 'DS'],
      'Thursday': ['DEVC', 'CHE', 'BCE', 'Free', 'EWS'],
      'Friday': ['DS LAB', 'CE', 'BME', 'Free', 'CHE'],
      'Saturday': ['DS', 'DEVC', 'CE', 'Free', 'EAA'],
    },
    'CSE-AIML_D': {
      'Monday': ['CHE', 'BCE', 'CE', 'Free', 'DS LAB'],
      'Tuesday': ['DS', 'CHE', 'SS', 'Free', 'BME'],
      'Wednesday': ['BCE', 'CE', 'DEVC', 'Free', 'CE LAB'],
      'Thursday': ['DS LAB', 'CE', 'Free', 'CHE', 'DEVC'],
      'Friday': ['CHE LAB', 'Free', 'Free', 'DS', 'EAA'],
      'Saturday': ['DEVC', 'BME', 'CE', 'Free', 'EWS'],
    },

    // ================= CSE (CORE) SECTIONS =================
    'CSE_A': {
      'Monday': ['ITWS', 'DS', 'Free', 'EEEW LAB', 'Free'],
      'Tuesday': ['EG', 'EP', 'Free', 'DS LAB', 'Free'],
      'Wednesday': ['EEEW LAB', 'BEE B', 'DS LAB', 'Free', 'DEVC'],
      'Thursday': ['DEVC', 'BEE B', 'BEE A', 'Free', 'EP'],
      'Friday': ['EP LAB', 'DS', 'Free', 'Free', 'EAA'],
      'Saturday': ['DEVC', 'SS', 'BEE A', 'Free', 'EG'],
    },
    'CSE_B': {
      'Monday': ['BEE A', 'DS', 'Free', 'EG', 'ITWS'],
      'Tuesday': ['BEE B', 'EG', 'Free', 'EP', 'DS LAB'],
      'Wednesday': ['DEVC', 'BEE A', 'Free', 'DS LAB', 'DEVC'],
      'Thursday': ['DS', 'BEE B', 'Free', 'DEVC', 'EEEW LAB'],
      'Friday': ['EEEW LAB', 'DS', 'SS', 'Free', 'EP LAB'],
      'Saturday': ['EP', 'Free', 'Free', 'Free', 'EAA'],
    },
    'CSE_C': {
      'Monday': ['EP LAB', 'DEVC', 'Free', 'DS', 'Free'],
      'Tuesday': ['EP', 'BEE B', 'EEEW LAB', 'Free', 'SS'],
      'Wednesday': ['EG', 'DEVC', 'Free', 'DS LAB', 'Free'],
      'Thursday': ['BEE B', 'BEE A', 'DS LAB', 'Free', 'EP'],
      'Friday': ['EEEW LAB', 'DS', 'BEE A', 'Free', 'EAA'],
      'Saturday': ['EG', 'DS', 'Free', 'ITWS', 'Free'],
    },
    'CSE_D': {
      'Monday': ['EEEW LAB', 'BEE B', 'Free', 'EP', 'DS'],
      'Tuesday': ['EG', 'Free', 'Free', 'DS LAB', 'DEVC'],
      'Wednesday': ['DS', 'BEE A', 'EP', 'Free', 'EP LAB'],
      'Thursday': ['BEE A', 'SS', 'Free', 'BEE B', 'DS LAB'],
      'Friday': ['EG', 'DS', 'EP', 'Free', 'EEEW LAB'],
      'Saturday': ['ITWS', 'Free', 'Free', 'DEVC', 'EAA'],
    },
    'CSE_E': {
      'Monday': ['DS', 'BEE B', 'EEEW LAB', 'Free', 'DEVC'],
      'Tuesday': ['DS', 'EP', 'DS LAB', 'Free', 'BEE A'],
      'Wednesday': ['EG', 'DS LAB', 'Free', 'SS', 'Free'],
      'Thursday': ['EEEW LAB', 'DEVC', 'EP', 'Free', 'EAA'],
      'Friday': ['DS', 'BEE B', 'DEVC', 'Free', 'ITWS'],
      'Saturday': ['EP LAB', 'BEE A', 'Free', 'EG', 'Free'],
    },
    // CSE-F shares with DS-D
    'CSE_F': {
      'Monday': ['EG', 'Free', 'Free', 'EP', 'DEVC'],
      'Tuesday': ['BEE A', 'DS', 'DS LAB', 'Free', 'SS'],
      'Wednesday': ['DEVC', 'BEE A', 'EP', 'DS LAB', 'Free'],
      'Thursday': ['EP LAB', 'Free', 'Free', 'BEE B', 'ITWS'],
      'Friday': ['BEE B', 'DS', 'Free', 'EEEW LAB', 'EAA'],
      'Saturday': ['EG', 'Free', 'Free', 'DS', 'EEEW LAB'],
    },

    // ================= CSE (DS) SECTIONS =================
    'CSE-DS_A': {
      'Monday': ['BEE A', 'DS', 'DEVC', 'EP', 'Free'],
      'Tuesday': ['EEEW LAB', 'DEVC', 'BEE A', 'Free', 'ITWS'],
      'Wednesday': ['EP LAB', 'Free', 'DS LAB', 'DS', 'BEE B'],
      'Thursday': ['EG', 'Free', 'Free', 'EEEW LAB', 'EAA'],
      'Friday': ['BEE B', 'DEVC', 'DS LAB', 'Free', 'SS'],
      'Saturday': ['EG', 'Free', 'Free', 'EP', 'DS'],
    },
    'CSE-DS_B': {
      'Monday': ['BEE B', 'DEVC', 'EP', 'Free', 'SS'],
      'Tuesday': ['DS', 'BEE B', 'Free', 'EG', 'ITWS'],
      'Wednesday': ['DS LAB', 'DEVC', 'Free', 'BEE A', 'EP'],
      'Thursday': ['Free', 'Free', 'Free', 'EG', 'EEEW LAB'],
      'Friday': ['Free', 'Free', 'Free', 'BEE A', 'EP'],
      'Saturday': ['Free', 'Free', 'Free', 'DEVC', 'EAA'],
    },
    'CSE-DS_C': {
      'Monday': ['BEE B', 'DEVC', 'DS LAB', 'Free', 'BEE A'],
      'Tuesday': ['EP LAB', 'Free', 'BEE B', 'Free', 'EG'],
      'Wednesday': ['BEE A', 'DS', 'Free', 'SS', 'EEEW LAB'],
      'Thursday': ['ITWS', 'Free', 'EP', 'Free', 'DS'],
      'Friday': ['EG', 'Free', 'DEVC', 'Free', 'EAA'],
      'Saturday': ['DS LAB', 'BEE B', 'Free', 'EEEW LAB', 'EP'],
    },
    // DS-D shares with CSE-F
    'CSE-DS_D': {
      'Monday': ['EG', 'Free', 'Free', 'EP', 'DEVC'],
      'Tuesday': ['BEE A', 'DS', 'DS LAB', 'Free', 'SS'],
      'Wednesday': ['DEVC', 'BEE A', 'EP', 'DS LAB', 'Free'],
      'Thursday': ['EP LAB', 'Free', 'Free', 'BEE B', 'ITWS'],
      'Friday': ['BEE B', 'DS', 'Free', 'EEEW LAB', 'EAA'],
      'Saturday': ['EG', 'Free', 'Free', 'DS', 'EEEW LAB'],
    },

    // ================= CSE (CS) SECTIONS =================
    'CSE-CS_A': {
      'Monday': ['BEE A', 'DS', 'DEVC', 'Free', 'EP LAB'],
      'Tuesday': ['Free', 'ITWS', 'BEE A', 'Free', 'EG'],
      'Wednesday': ['BEE B', 'DEVC', 'Free', 'SS', 'DS LAB'],
      'Thursday': ['EP', 'BEE B', 'Free', 'EEEW LAB', 'DEVC'],
      'Friday': ['Free', 'EG', 'Free', 'DS', 'EAA'],
      'Saturday': ['EP', 'DS', 'Free', 'DS LAB', 'EEEW LAB'],
    },
    'CSE-CS_B': {
      'Monday': ['DS', 'DEVC', 'BEE A', 'EG', 'Free'],
      'Tuesday': ['BEE A', 'DEVC', 'EP', 'EP LAB', 'Free'],
      'Wednesday': ['ITWS', 'Free', 'EEEW LAB', 'Free', 'DS'],
      'Thursday': ['BEE B', 'EP', 'DEVC', 'EAA', 'Free'],
      'Friday': ['EG', 'Free', 'SS', 'DS LAB', 'Free'],
      'Saturday': ['EP', 'BEE B', 'EEEW LAB', 'DS LAB', 'Free'],
    },
  };
}
