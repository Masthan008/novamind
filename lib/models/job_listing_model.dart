class JobListing {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final String redirectUrl;
  final double? salaryMin;
  final double? salaryMax;
  final DateTime created;
  final String category;
  final String? contractType;
  final bool isFeatured;
  bool isSaved;

  JobListing({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.redirectUrl,
    this.salaryMin,
    this.salaryMax,
    required this.created,
    this.category = '',
    this.contractType,
    this.isFeatured = false,
    this.isSaved = false,
  });

  /// Parse from Adzuna API JSON
  factory JobListing.fromAdzuna(Map<String, dynamic> json) {
    return JobListing(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',
      company: json['company']?['display_name'] ?? 'Unknown Company',
      location: json['location']?['display_name'] ?? 'India',
      description: json['description'] ?? '',
      redirectUrl: json['redirect_url'] ?? '',
      salaryMin: (json['salary_min'] as num?)?.toDouble(),
      salaryMax: (json['salary_max'] as num?)?.toDouble(),
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      category: json['category']?['label'] ?? '',
      contractType: json['contract_type'],
      isFeatured: false,
    );
  }

  /// Parse from Supabase featured job
  factory JobListing.fromSupabase(Map<String, dynamic> json) {
    return JobListing(
      id: 'featured_${json['id']}',
      title: json['title'] ?? 'Untitled',
      company: json['company'] ?? 'Unknown Company',
      location: json['location'] ?? 'India',
      description: json['description'] ?? '',
      redirectUrl: json['redirect_url'] ?? json['apply_url'] ?? '',
      salaryMin: (json['salary_min'] as num?)?.toDouble(),
      salaryMax: (json['salary_max'] as num?)?.toDouble(),
      created: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      category: json['category'] ?? '',
      contractType: json['contract_type'],
      isFeatured: true,
    );
  }

  /// Parse from Supabase saved job
  factory JobListing.fromSaved(Map<String, dynamic> json) {
    return JobListing(
      id: json['job_id'] ?? '',
      title: json['title'] ?? 'Untitled',
      company: json['company'] ?? 'Unknown Company',
      location: json['location'] ?? 'India',
      description: json['description'] ?? '',
      redirectUrl: json['redirect_url'] ?? '',
      salaryMin: (json['salary_min'] as num?)?.toDouble(),
      salaryMax: (json['salary_max'] as num?)?.toDouble(),
      created: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      category: json['category'] ?? '',
      contractType: json['contract_type'],
      isFeatured: json['is_featured'] ?? false,
      isSaved: true,
    );
  }

  /// Convert to map for Supabase saved_jobs insert
  Map<String, dynamic> toSavedMap(String userId) {
    return {
      'user_id': userId,
      'job_id': id,
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'redirect_url': redirectUrl,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'category': category,
      'contract_type': contractType,
      'is_featured': isFeatured,
    };
  }

  /// Format salary range as readable string
  String get salaryDisplay {
    if (salaryMin == null && salaryMax == null) return 'Not disclosed';
    final min = salaryMin != null ? '₹${_formatNumber(salaryMin!)}' : '';
    final max = salaryMax != null ? '₹${_formatNumber(salaryMax!)}' : '';
    if (min.isNotEmpty && max.isNotEmpty) return '$min - $max';
    if (min.isNotEmpty) return '$min+';
    return 'Up to $max';
  }

  String _formatNumber(double n) {
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }

  /// Days since posted
  int get daysSincePosted => DateTime.now().difference(created).inDays;

  String get timeAgo {
    final days = daysSincePosted;
    if (days == 0) return 'Today';
    if (days == 1) return '1 day ago';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).floor()} weeks ago';
    return '${(days / 30).floor()} months ago';
  }
}
