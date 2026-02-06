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
  // WEF: 05.02.2026 | Updated from 22 Timetable Images
  static final Map<String, Map<String, List<String>>> allSchedules = {

    // ================= ECE SECTIONS (Updated from Images) =================
    'ECE_A': {
      'Monday': ['CHE', 'CE', 'DEVC', 'Free', 'NWA LAB'],
      'Tuesday': ['CHE LAB', 'CHE LAB', 'BME', 'CE', 'Free'],
      'Wednesday': ['DEVC', 'CHE', 'NWA', 'Free', 'EWS'],
      'Thursday': ['NWA', 'BME', 'SS', 'BCE', 'Free'],
      'Friday': ['CE LAB', 'CE LAB', 'BCE', 'CE', 'CHE'],
      'Saturday': ['DEVC', 'CE', 'NWA', 'Free', 'EAA'],
    },
    'ECE_B': {
      'Monday': ['SS', 'CE', 'DEVC', 'Free', 'EWS'],
      'Tuesday': ['BCE', 'CHE', 'DEVC', 'Free', 'NWA'],
      'Wednesday': ['CHE', 'CE', 'BME', 'Free', 'NWA LAB'],
      'Thursday': ['CHE LAB', 'CHE LAB', 'NWA', 'Free', 'EAA'],
      'Friday': ['CE', 'BCE', 'NWA', 'Free', 'CE LAB'],
      'Saturday': ['DEVC', 'CE', 'BME', 'Free', 'CHE'],
    },
    'ECE_C': {
      'Monday': ['CE', 'BME', 'SS', 'Free', 'BCE'],
      'Tuesday': ['DEVC', 'NWA', 'CE', 'Free', 'NWA LAB'],
      'Wednesday': ['CHE', 'DEVC', 'CE', 'Free', 'DEVC+BME'],
      'Thursday': ['CE LAB', 'CE LAB', 'NWA', 'Free', 'CHE'],
      'Friday': ['DEVC', 'BME', 'CHE', 'Free', 'BCE+EWS'],
      'Saturday': ['CHE LAB', 'CHE LAB', 'NWA', 'Free', 'EAA'],
    },
    // ECE-D and EEE-B share the same timetable
    'ECE_D': {
      'Monday': ['CHE', 'BCE', 'CE', 'Free', 'BME'],
      'Tuesday': ['SS', 'NWA/ECA', 'DEVC', 'Free', 'CHE LAB'],
      'Wednesday': ['DEVC', 'CHE', 'BCE', 'Free', 'CE'],
      'Thursday': ['EWS', 'NWA/ECA', 'Free', 'Free', 'EAA'],
      'Friday': ['DEVC', 'BME', 'CHE', 'Free', 'NWA/ECA LAB'],
      'Saturday': ['NWA/ECA', 'CHE', 'CE', 'Free', 'CE LAB'],
    },

    // ================= EEE SECTIONS (Updated from Images) =================
    'EEE_A': {
      'Monday': ['DEVC', 'CE', 'ECA', 'Free', 'CHE LAB'],
      'Tuesday': ['ECA', 'BCE', 'CHE', 'Free', 'EWS'],
      'Wednesday': ['CE', 'DEVC', 'BME', 'Free', 'ECA LAB'],
      'Thursday': ['SS', 'ECA', 'CE', 'Free', 'CE LAB'],
      'Friday': ['BCE', 'CE', 'CHE', 'Free', 'DEVC'],
      'Saturday': ['BME', 'ECA', 'CHE', 'Free', 'EAA'],
    },
    // EEE-B shares timetable with ECE-D
    'EEE_B': {
      'Monday': ['CHE', 'BCE', 'CE', 'Free', 'BME'],
      'Tuesday': ['SS', 'NWA/ECA', 'DEVC', 'Free', 'CHE LAB'],
      'Wednesday': ['DEVC', 'CHE', 'BCE', 'Free', 'CE'],
      'Thursday': ['EWS', 'NWA/ECA', 'Free', 'Free', 'EAA'],
      'Friday': ['DEVC', 'BME', 'CHE', 'Free', 'NWA/ECA LAB'],
      'Saturday': ['NWA/ECA', 'CHE', 'CE', 'Free', 'CE LAB'],
    },

    // ================= ME SECTIONS (Updated from Images) =================
    'ME_A': {
      'Monday': ['CE LAB', 'CE LAB', 'BME', 'Free', 'SS'],
      'Tuesday': ['CE', 'BME', 'EM', 'Free', 'EM LAB'],
      'Wednesday': ['DEVC', 'BCE', 'CHE', 'Free', 'EM'],
      'Thursday': ['CHE', 'DEVC', 'BCE', 'Free', 'CE'],
      'Friday': ['EWS', 'Free', 'EM', 'Free', 'EAA'],
      'Saturday': ['DEVC', 'CE', 'CHE', 'Free', 'CHE LAB'],
    },
    // ME-B shares timetable with CIVIL
    'ME_B': {
      'Monday': ['BCE', 'EM', 'CE', 'Free', 'CHE'],
      'Tuesday': ['EM', 'BCE', 'DEVC', 'Free', 'CE LAB'],
      'Wednesday': ['EWS', 'Free', 'DEVC', 'Free', 'CE'],
      'Thursday': ['CHE', 'EM', 'BME', 'Free', 'EM LAB'],
      'Friday': ['SS', 'EM', 'CHE', 'Free', 'CHE LAB'],
      'Saturday': ['DEVC', 'CE', 'BME', 'Free', 'EAA'],
    },

    // ================= CIVIL SECTION (Updated from Images) =================
    'CIVIL_A': {
      'Monday': ['BCE', 'EM', 'CE', 'Free', 'CHE'],
      'Tuesday': ['EM', 'BCE', 'DEVC', 'Free', 'CE LAB'],
      'Wednesday': ['EWS', 'Free', 'DEVC', 'Free', 'CE'],
      'Thursday': ['CHE', 'EM', 'BME', 'Free', 'EM LAB'],
      'Friday': ['SS', 'EM', 'CHE', 'Free', 'CHE LAB'],
      'Saturday': ['DEVC', 'CE', 'BME', 'Free', 'EAA'],
    },

    // ================= CSE (AI&ML) SECTIONS (Updated from Images) =================
    'CSE-AIML_A': {
      'Monday': ['DEVC', 'CE', 'BCE', 'Free', 'DS'],
      'Tuesday': ['EWS', 'Free', 'CE', 'Free', 'CHE'],
      'Wednesday': ['DEVC', 'CHE', 'DS LAB', 'DS LAB', 'BME'],
      'Thursday': ['DS', 'BCE', 'DEVC', 'Free', 'CHE LAB'],
      'Friday': ['CHE', 'BME', 'DS LAB', 'DS LAB', 'CE'],
      'Saturday': ['CE LAB', 'CE LAB', 'SS', 'Free', 'EAA'],
    },
    'CSE-AIML_B': {
      'Monday': ['DS', 'BME', 'CHE', 'Free', 'CE LAB'],
      'Tuesday': ['CHE', 'DEVC', 'DS LAB', 'DS LAB', 'BCE'],
      'Wednesday': ['CHE LAB', 'CHE LAB', 'CE', 'Free', 'DS'],
      'Thursday': ['DEVC', 'CE', 'DS LAB', 'DS LAB', 'CHE'],
      'Friday': ['CE', 'BCE', 'BME', 'Free', 'EAA'],
      'Saturday': ['EWS', 'Free', 'DEVC', 'Free', 'SS'],
    },
    'CSE-AIML_C': {
      'Monday': ['CHE LAB', 'CHE LAB', 'CE', 'Free', 'DEVC'],
      'Tuesday': ['BCE', 'BME', 'SS', 'Free', 'DS LAB'],
      'Wednesday': ['CE LAB', 'CE LAB', 'CHE', 'Free', 'DS'],
      'Thursday': ['DEVC', 'CHE', 'BCE', 'Free', 'EWS'],
      'Friday': ['DS LAB', 'CE', 'BME', 'Free', 'CHE'],
      'Saturday': ['DS', 'DEVC', 'CE', 'Free', 'EAA'],
    },
    'CSE-AIML_D': {
      'Monday': ['CHE', 'BCE', 'CE', 'Free', 'DS LAB'],
      'Tuesday': ['DS', 'CHE', 'SS', 'Free', 'BME'],
      'Wednesday': ['BCE', 'CE', 'DEVC', 'Free', 'CE LAB'],
      'Thursday': ['DS LAB', 'CE', 'CHE', 'Free', 'DEVC'],
      'Friday': ['CHE LAB', 'CHE LAB', 'DS', 'Free', 'EAA'],
      'Saturday': ['DEVC', 'BME', 'CE', 'Free', 'EWS'],
    },

    // ================= CSE (CORE) SECTIONS (Keeping existing as no new data) =================
    'CSE_A': {
      'Monday': ['ITWS', 'Free', 'DS', 'Free', 'EEEW LAB'],
      'Tuesday': ['EG', 'Free', 'EP', 'Free', 'DS LAB'],
      'Wednesday': ['EEEW LAB', 'BEE B', 'DS LAB', 'Free', 'DEVC'],
      'Thursday': ['BEE B', 'DEVC', 'BEE A', 'Free', 'EP'],
      'Friday': ['EP LAB', 'Free', 'DS', 'Free', 'EAA'],
      'Saturday': ['SS', 'DEVC', 'BEE A', 'Free', 'EG'],
    },
    'CSE_B': {
      'Monday': ['BEE A', 'DEVC', 'DS', 'Free', 'ITWS'],
      'Tuesday': ['EG', 'Free', 'EP', 'Free', 'DS LAB'],
      'Wednesday': ['BEE B', 'BEE A', 'DS LAB', 'Free', 'DEVC'],
      'Thursday': ['EG', 'Free', 'SS', 'Free', 'EEEW LAB'],
      'Friday': ['DS', 'BEE B', 'DEVC', 'Free', 'EP LAB'],
      'Saturday': ['EEEW LAB', 'DS', 'EP', 'Free', 'EAA'],
    },
    'CSE_C': {
      'Monday': ['EP LAB', 'Free', 'DEVC', 'Free', 'DS'],
      'Tuesday': ['EP', 'BEE B', 'EEEW LAB', 'Free', 'SS'],
      'Wednesday': ['EG', 'Free', 'DEVC', 'Free', 'DS LAB'],
      'Thursday': ['BEE B', 'BEE A', 'DS LAB', 'Free', 'EP'],
      'Friday': ['EEEW LAB', 'DS', 'BEE A', 'Free', 'EAA'],
      'Saturday': ['EG', 'DS', 'Free', 'ITWS', 'Free'],
    },
    'CSE_D': {
      'Monday': ['EEEW LAB', 'BEE B', 'EP', 'Free', 'DS'],
      'Tuesday': ['EG', 'Free', 'DS LAB', 'Free', 'DEVC'],
      'Wednesday': ['BEE A', 'DS', 'EP', 'Free', 'EP LAB'],
      'Thursday': ['SS', 'BEE A', 'BEE B', 'Free', 'DS LAB'],
      'Friday': ['EG', 'DS', 'EP', 'Free', 'EEEW LAB'],
      'Saturday': ['ITWS', 'Free', 'DEVC', 'Free', 'EAA'],
    },
    'CSE_E': {
      'Monday': ['DS', 'BEE B', 'EEEW LAB', 'Free', 'DEVC'],
      'Tuesday': ['EP', 'DS', 'DS LAB', 'Free', 'BEE A'],
      'Wednesday': ['EG', 'Free', 'DS LAB', 'Free', 'SS'],
      'Thursday': ['EEEW LAB', 'DEVC', 'EP', 'Free', 'EAA'],
      'Friday': ['BEE B', 'DS', 'DEVC', 'Free', 'ITWS'],
      'Saturday': ['EP LAB', 'BEE A', 'BEE A', 'Free', 'EG'],
    },

    // ================= CSE (DS) SECTIONS (Updated from Images) =================
    'CSE-DS_A': {
      'Monday': ['BEE A', 'DS', 'DEVC', 'Free', 'EP'],
      'Tuesday': ['EEEW LAB', 'EEEW LAB', 'DEVC', 'Free', 'ITWS'],
      'Wednesday': ['EP LAB', 'Free', 'DS LAB', 'DS LAB', 'DS+BEE B'],
      'Thursday': ['EG', 'Free', 'EEEW LAB', 'EEEW LAB', 'EAA'],
      'Friday': ['BEE B', 'DEVC', 'DS LAB', 'DS LAB', 'SS'],
      'Saturday': ['EG', 'Free', 'EP', 'Free', 'DS'],
    },
    'CSE-DS_B': {
      'Monday': ['BEE B', 'DEVC', 'EP', 'Free', 'EG'],
      'Tuesday': ['DS', 'BEE B', 'DS LAB', 'DS LAB', 'EEEW LAB'],
      'Wednesday': ['DS LAB', 'DEVC', 'BEE A', 'Free', 'EP'],
      'Thursday': ['EG', 'Free', 'DS', 'Free', 'EEEW LAB'],
      'Friday': ['ITWS', 'DEVC', 'Free', 'Free', 'EAA'],
      'Saturday': ['SS', 'BEE A', 'EP', 'Free', 'EP LAB'],
    },
    'CSE-DS_C': {
      'Monday': ['DEVC', 'BEE B', 'DS LAB', 'DS LAB', 'BEE A'],
      'Tuesday': ['EP LAB', 'BEE B', 'EG', 'Free', 'EG'],
      'Wednesday': ['BEE A', 'DS', 'SS', 'Free', 'EEEW LAB'],
      'Thursday': ['ITWS', 'Free', 'EP', 'Free', 'DS'],
      'Friday': ['EG', 'DEVC', 'Free', 'Free', 'EAA'],
      'Saturday': ['DS LAB', 'BEE B', 'EEEW LAB', 'EEEW LAB', 'EP'],
    },
    // CSE-F and DS-D share the same timetable (Updated from Images)
    'CSE_F': {
      'Monday': ['Free', 'EG', 'EP', 'Free', 'DEVC'],
      'Tuesday': ['BEE A', 'DS', 'DS LAB', 'DS LAB', 'SS'],
      'Wednesday': ['DEVC', 'BEE A', 'EP', 'Free', 'DS LAB'],
      'Thursday': ['EP LAB', 'BEE B', 'ITWS', 'Free', 'ITWS'],
      'Friday': ['BEE B', 'DS', 'EEEW LAB', 'EEEW LAB', 'EAA'],
      'Saturday': ['EG', 'DS', 'Free', 'Free', 'EEEW LAB'],
    },
    'CSE-DS_D': {
      'Monday': ['Free', 'EG', 'EP', 'Free', 'DEVC'],
      'Tuesday': ['BEE A', 'DS', 'DS LAB', 'DS LAB', 'SS'],
      'Wednesday': ['DEVC', 'BEE A', 'EP', 'Free', 'DS LAB'],
      'Thursday': ['EP LAB', 'BEE B', 'ITWS', 'Free', 'ITWS'],
      'Friday': ['BEE B', 'DS', 'EEEW LAB', 'EEEW LAB', 'EAA'],
      'Saturday': ['EG', 'DS', 'Free', 'Free', 'EEEW LAB'],
    },

    // ================= CSE (CS) SECTIONS (Updated from Images) =================
    'CSE-CS_A': {
      'Monday': ['BEE A', 'DS', 'DEVC', 'Free', 'EP LAB'],
      'Tuesday': ['ITWS', 'BEE A', 'EG', 'Free', 'Free'],
      'Wednesday': ['BEE B', 'DEVC', 'SS', 'Free', 'DS LAB'],
      'Thursday': ['EP', 'BEE B', 'EEEW LAB', 'EEEW LAB', 'DEVC'],
      'Friday': ['EG', 'DS', 'Free', 'Free', 'EAA'],
      'Saturday': ['EP', 'DS', 'DS LAB', 'DS LAB', 'EEEW LAB'],
    },
    'CSE-CS_B': {
      'Monday': ['DS', 'DEVC', 'BEE A', 'Free', 'EG'],
      'Tuesday': ['BEE A', 'DEVC', 'EP', 'Free', 'EP LAB'],
      'Wednesday': ['ITWS', 'Free', 'EEEW LAB', 'EEEW LAB', 'DS'],
      'Thursday': ['BEE B', 'EP', 'DEVC', 'Free', 'EAA'],
      'Friday': ['EG', 'Free', 'SS', 'Free', 'DS LAB'],
      'Saturday': ['EP', 'BEE B', 'Free', 'EEEW LAB', 'DS LAB'],
    },
  };
}
