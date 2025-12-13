// Reciter and Audio Model - نموذج القراء والتلاوات

class Reciter {
  final String id;
  final String nameArabic;
  final String nameEnglish;
  final String country;
  final String style; // مرتل، مجود، معلم
  final String serverUrl;
  final String? imageUrl;

  Reciter({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.country,
    required this.style,
    required this.serverUrl,
    this.imageUrl,
  });

  // Popular reciters
  static List<Reciter> get popularReciters => [
    Reciter(
      id: 'abdulbasit_mujawwad',
      nameArabic: 'عبد الباسط عبد الصمد - مجود',
      nameEnglish: 'Abdul Basit Abdul Samad (Mujawwad)',
      country: 'مصر',
      style: 'مجود',
      serverUrl: 'https://server8.mp3quran.net/abas/',
    ),
    Reciter(
      id: 'abdulbasit_murattal',
      nameArabic: 'عبد الباسط عبد الصمد - مرتل',
      nameEnglish: 'Abdul Basit Abdul Samad (Murattal)',
      country: 'مصر',
      style: 'مرتل',
      serverUrl: 'https://server7.mp3quran.net/basit/',
    ),
    Reciter(
      id: 'husary',
      nameArabic: 'محمود خليل الحصري',
      nameEnglish: 'Mahmoud Khalil Al-Husary',
      country: 'مصر',
      style: 'مرتل',
      serverUrl: 'https://server13.mp3quran.net/husr/',
    ),
    Reciter(
      id: 'minshawi',
      nameArabic: 'محمد صديق المنشاوي',
      nameEnglish: 'Mohamed Siddiq Al-Minshawi',
      country: 'مصر',
      style: 'مجود',
      serverUrl: 'https://server10.mp3quran.net/minsh/',
    ),
    Reciter(
      id: 'afasy',
      nameArabic: 'مشاري بن راشد العفاسي',
      nameEnglish: 'Mishari Rashid Al-Afasy',
      country: 'الكويت',
      style: 'مرتل',
      serverUrl: 'https://server8.mp3quran.net/afs/',
    ),
    Reciter(
      id: 'sudais',
      nameArabic: 'عبد الرحمن السديس',
      nameEnglish: 'Abdul Rahman Al-Sudais',
      country: 'السعودية',
      style: 'مرتل',
      serverUrl: 'https://server11.mp3quran.net/sds/',
    ),
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameArabic': nameArabic,
      'nameEnglish': nameEnglish,
      'country': country,
      'style': style,
      'serverUrl': serverUrl,
      'imageUrl': imageUrl,
    };
  }

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'] as String,
      nameArabic: json['nameArabic'] as String,
      nameEnglish: json['nameEnglish'] as String,
      country: json['country'] as String,
      style: json['style'] as String,
      serverUrl: json['serverUrl'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class RecitationTrack {
  final String reciterId;
  final int surahNumber;
  final String? audioUrl;
  final bool isDownloaded;
  final String? localPath;
  final int? fileSizeBytes;
  final Duration? duration;

  RecitationTrack({
    required this.reciterId,
    required this.surahNumber,
    this.audioUrl,
    this.isDownloaded = false,
    this.localPath,
    this.fileSizeBytes,
    this.duration,
  });

  // Generate audio URL for a surah
  String getAudioUrl(Reciter reciter) {
    if (audioUrl != null) return audioUrl!;
    // Format: 001.mp3, 002.mp3, etc.
    final surahString = surahNumber.toString().padLeft(3, '0');
    return '${reciter.serverUrl}$surahString.mp3';
  }

  RecitationTrack copyWith({
    String? reciterId,
    int? surahNumber,
    String? audioUrl,
    bool? isDownloaded,
    String? localPath,
    int? fileSizeBytes,
    Duration? duration,
  }) {
    return RecitationTrack(
      reciterId: reciterId ?? this.reciterId,
      surahNumber: surahNumber ?? this.surahNumber,
      audioUrl: audioUrl ?? this.audioUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reciterId': reciterId,
      'surahNumber': surahNumber,
      'audioUrl': audioUrl,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
      'fileSizeBytes': fileSizeBytes,
      'durationSeconds': duration?.inSeconds,
    };
  }

  factory RecitationTrack.fromJson(Map<String, dynamic> json) {
    return RecitationTrack(
      reciterId: json['reciterId'] as String,
      surahNumber: json['surahNumber'] as int,
      audioUrl: json['audioUrl'] as String?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
      fileSizeBytes: json['fileSizeBytes'] as int?,
      duration: json['durationSeconds'] != null
          ? Duration(seconds: json['durationSeconds'] as int)
          : null,
    );
  }
}

enum PlaybackState { idle, loading, playing, paused, completed, error }

class AudioPlayerState {
  final PlaybackState state;
  final Duration position;
  final Duration duration;
  final double speed;
  final RecitationTrack? currentTrack;
  final Reciter? currentReciter;
  final String? errorMessage;

  AudioPlayerState({
    this.state = PlaybackState.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.currentTrack,
    this.currentReciter,
    this.errorMessage,
  });

  AudioPlayerState copyWith({
    PlaybackState? state,
    Duration? position,
    Duration? duration,
    double? speed,
    RecitationTrack? currentTrack,
    Reciter? currentReciter,
    String? errorMessage,
  }) {
    return AudioPlayerState(
      state: state ?? this.state,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      currentTrack: currentTrack ?? this.currentTrack,
      currentReciter: currentReciter ?? this.currentReciter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isPlaying => state == PlaybackState.playing;
  bool get isPaused => state == PlaybackState.paused;
  bool get isLoading => state == PlaybackState.loading;

  double get progress {
    if (duration.inSeconds == 0) return 0.0;
    return position.inSeconds / duration.inSeconds;
  }
}
