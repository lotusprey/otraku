// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'gen.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get accountAdd => 'Hesap Ekle';

  @override
  String get accountAddWarning =>
      'Daha fazla hesap eklemek için tarayıcıda önceki hesapların oturumunu kapatmış olmalısınız.';

  @override
  String get accountExpired => 'Süresi Doldu';

  @override
  String accountExpiresIn(String amount) {
    return '$amount içinde sona erecek';
  }

  @override
  String get accountGuest => 'Misafir';

  @override
  String get accountLogIn => 'Oturum Aç';

  @override
  String get accountLogInAgainQuestion => 'Yeniden oturum açmak istiyor musunuz?';

  @override
  String get accountLoginInstructions => 'Bu içeriğe erişmek için oturum açın.';

  @override
  String get accountLoginRequired => 'Oturum Açılması Gerekiyor';

  @override
  String get accountRemove => 'Hesabı Kaldır';

  @override
  String get accountRemoveQuestion => 'Hesap kaldırılsın mı?';

  @override
  String get accountSessionExpired => 'Oturum Süresi Doldu';

  @override
  String get accountSwitch => 'Hesap Değiştir';

  @override
  String get actionAdd => 'Ekle';

  @override
  String get actionAgreementAgree => 'Kabul Et';

  @override
  String get actionAgreementDisagree => 'Reddet';

  @override
  String get actionApply => 'Uygula';

  @override
  String get actionCancel => 'İptal';

  @override
  String get actionClear => 'Temizle';

  @override
  String get actionCollectionLoad => 'Tüm Koleksiyonu Yükle';

  @override
  String get actionConfirm => 'Onayla';

  @override
  String get actionCopy => 'Kopyala';

  @override
  String get actionCopyLink => 'Bağlantıyı Kopyala';

  @override
  String get actionDownload => 'İndir';

  @override
  String get actionEdit => 'Düzenle';

  @override
  String get actionGoBack => 'Geri Dön';

  @override
  String get actionMore => 'Daha Fazla';

  @override
  String get actionNo => 'Hayır';

  @override
  String get actionOk => 'Tamam';

  @override
  String get actionOpenInBrowser => 'Tarayıcıda Aç';

  @override
  String get actionOpenVideoInBrowser => 'Videoyu Tarayıcıda Aç';

  @override
  String get actionRemove => 'Kaldır';

  @override
  String get actionRemoveQuestion => 'Kaldırılsın mı?';

  @override
  String get actionRename => 'Yeniden Adlandır';

  @override
  String get actionReset => 'Sıfırla';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionShare => 'Paylaş';

  @override
  String get actionSpoilersHide => 'Spoilerları Gizle';

  @override
  String get actionSpoilersShow => 'Spoilerları Göster';

  @override
  String get actionYes => 'Evet';

  @override
  String get activities => 'Etkinlikler';

  @override
  String get all => 'Tümü';

  @override
  String get animeCollection => 'Anime Koleksiyonu';

  @override
  String get appName => 'Otraku';

  @override
  String get calendar => 'Takvim';

  @override
  String get characters => 'Karakterler';

  @override
  String get comments => 'Yorumlar';

  @override
  String get compositionsAdd => 'Oluştur';

  @override
  String get compositionsPreview => 'Önizleme';

  @override
  String get country => 'Ülke';

  @override
  String get countryChina => 'Çin';

  @override
  String get countryJapan => 'Japonya';

  @override
  String get countrySouthKorea => 'Güney Kore';

  @override
  String get countryTaiwan => 'Tayvan';

  @override
  String dateTimeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün önce',
      one: '1 gün önce',
    );
    return '$_temp0';
  }

  @override
  String dateTimeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saat önce',
      one: '1 saat önce',
    );
    return '$_temp0';
  }

  @override
  String dateTimeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dakika önce',
      one: '1 dakika önce',
    );
    return '$_temp0';
  }

  @override
  String dateTimeAgoMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ay önce',
      one: '1 ay önce',
    );
    return '$_temp0';
  }

  @override
  String dateTimeAgoSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saniye önce',
      one: '1 saniye önce',
    );
    return '$_temp0';
  }

  @override
  String dateTimeAgoYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yıl önce',
      one: '1 yıl önce',
    );
    return '$_temp0';
  }

  @override
  String get dateTimeCreationTime => 'Oluşturulma Tarihi';

  @override
  String get dateTimePresent => 'Günümüz';

  @override
  String get discover => 'Keşfet';

  @override
  String discoverCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Keşif Kategorileri',
      one: 'Keşif Kategorisi',
    );
    return '$_temp0';
  }

  @override
  String get enter => 'Giriş Yapın';

  @override
  String get entryChangedDateCompletion => 'Tamamlanma tarihi değiştirildi';

  @override
  String get entryChangedDateCompletionAndProgress => 'Tamamlanma tarihi ve ilerleme değiştirildi';

  @override
  String get entryChangedDateCompletionAndStatus => 'Tamamlanma tarihi ve durum değiştirildi';

  @override
  String get entryChangedDateStart => 'Başlangıç tarihi değiştirildi';

  @override
  String get entryChangedDateStartAndStatus => 'Başlangıç tarihi ve durum değiştirildi';

  @override
  String get entryChangedStatus => 'Durum değiştirildi';

  @override
  String get entryChangedStatusAndProgress => 'Durum ve ilerleme değiştirildi';

  @override
  String get entryComment => 'Yorum';

  @override
  String get entryCustomLists => 'Özel Listeler';

  @override
  String get entryDateCompleted => 'Tamamlandı';

  @override
  String get entryDateStarted => 'Başlandı';

  @override
  String get entryHiddenFromStatusLists => 'Durum Listelerinden Gizlendi';

  @override
  String get entryNotes => 'Notlar';

  @override
  String get entryPrivate => 'Gizli';

  @override
  String get entryProgress => 'İlerleme';

  @override
  String get entryProgressIncrement => 'İlerlemeyi Artır';

  @override
  String get entryProgressUpdateStatusQuestion => 'Liste durumunu da güncellemek istiyor musunuz?';

  @override
  String get entryProgressVolumes => 'Cilt İlerlemesi';

  @override
  String get entryRepeats => 'Tekrarlar';

  @override
  String get entryScore => 'Puan';

  @override
  String get entryScoreFaceDisliked => 'Beğenilmedi';

  @override
  String get entryScoreFaceLiked => 'Beğenildi';

  @override
  String get entryScoreFaceNeutral => 'Nötr';

  @override
  String get entryScoreRemove => 'Puanı Kaldır';

  @override
  String entryScoreStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yıldız ver',
      one: '1 yıldız ver',
    );
    return '$_temp0';
  }

  @override
  String get entryStatus => 'Durum';

  @override
  String get entryStatusCompleted => 'Tamamlandı';

  @override
  String get entryStatusCompletedAnime => 'Tamamlandı';

  @override
  String get entryStatusCompletedManga => 'Tamamlandı';

  @override
  String get entryStatusCurrent => 'Mevcut';

  @override
  String get entryStatusCurrentAnime => 'İzleniyor';

  @override
  String get entryStatusCurrentManga => 'Okunuyor';

  @override
  String get entryStatusDropped => 'Bırakıldı';

  @override
  String get entryStatusDroppedAnime => 'Bırakıldı';

  @override
  String get entryStatusDroppedManga => 'Bırakıldı';

  @override
  String get entryStatusPaused => 'Duraklatıldı';

  @override
  String get entryStatusPausedAnime => 'Duraklatıldı';

  @override
  String get entryStatusPausedManga => 'Duraklatıldı';

  @override
  String get entryStatusPlanning => 'Planlanıyor';

  @override
  String get entryStatusPlanningAnime => 'Planlanıyor';

  @override
  String get entryStatusPlanningManga => 'Planlanıyor';

  @override
  String get entryStatusRepeating => 'Tekrar Ediliyor';

  @override
  String get entryStatusRepeatingAnime => 'Tekrar İzleniyor';

  @override
  String get entryStatusRepeatingManga => 'Tekrar Okunuyor';

  @override
  String get errorAlreadyExists => 'Zaten Mevcut';

  @override
  String get errorDateInvalid => 'Tarih geçersiz';

  @override
  String get errorDateInvalidRange => 'Tarih geçerli bir aralıkta değil';

  @override
  String get errorFailedGettingFile => 'Dosya alınamadı';

  @override
  String errorFailedLoading(String error) {
    return 'Yükleme Başarısız: $error';
  }

  @override
  String errorFailedRemoving(String error) {
    return 'Kaldırma Başarısız: $error';
  }

  @override
  String errorFailedReordering(String error) {
    return 'Yeniden Sıralama Başarısız: $error';
  }

  @override
  String errorFailedUpdating(String error) {
    return 'Güncelleme Başarısız: $error';
  }

  @override
  String get errorMissingGalleryPermission => 'Galeri izni eksik';

  @override
  String get errorFieldRequired => 'Zorunlu Alan';

  @override
  String get errorUriInvalid => 'Geçersiz URI';

  @override
  String get externalLinks => 'Dış Bağlantılar';

  @override
  String get favorites => 'Favoriler';

  @override
  String get favoritesAdd => 'Favorilere Ekle';

  @override
  String favoritesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Favori',
      one: '1 Favori',
    );
    return '$_temp0';
  }

  @override
  String get favoritesRemove => 'Favorilerden Çıkar';

  @override
  String get feed => 'Akış';

  @override
  String get fileSaved => 'Dosya Kaydedildi';

  @override
  String get filter => 'Filtrele';

  @override
  String get filterActivitiesFollowed => 'Takip Edilenler';

  @override
  String get filterActivitiesGlobal => 'Genel';

  @override
  String get filterActivitiesSelf => 'Kendi';

  @override
  String get filterAge => 'Yaş Sınırlaması';

  @override
  String get filterAgeAdult => 'Yetişkin';

  @override
  String get filterAgeNonAdult => 'Yetişkin Olmayan';

  @override
  String get filterCategory => 'Kategori';

  @override
  String get filterDefaultQuestion => 'Varsayılan yapılsın mı?';

  @override
  String get filterDefaultWarning => 'Mevcut filtreler ve sıralama varsayılan hâle gelecektir.';

  @override
  String get filterLicensing => 'Lisanslama';

  @override
  String get filterLicensingDoujin => 'Doujin';

  @override
  String get filterLicensingLicensed => 'Lisanslı';

  @override
  String get filterListPresence => 'Listelerde Bulunma';

  @override
  String get filterListPresenceIn => 'Listelerde Var';

  @override
  String get filterListPresenceNotIn => 'Listelerde Yok';

  @override
  String get filterNotes => 'Notlar';

  @override
  String get filterNotesWith => 'Notlu';

  @override
  String get filterNotesWithout => 'Notsuz';

  @override
  String get filterReadableOn => 'Okunabileceği Platformlar';

  @override
  String get filterReleaseEnd => 'Yayın Bitişi';

  @override
  String get filterReleaseStart => 'Yayın Başlangıcı';

  @override
  String get filterShowAll => 'Tümünü Göster';

  @override
  String get filterShowBirthdayPeople => 'Doğum Günü Olanları Göster';

  @override
  String get filterSort => 'Sırala';

  @override
  String get filterSortPreview => 'Sıralama Önizleme';

  @override
  String get filterStudioRole => 'Stüdyo Rolü';

  @override
  String get filterStudioRoleMain => 'Ana Stüdyo';

  @override
  String get filterStudioRoleNotMain => 'Ana Stüdyo Değil';

  @override
  String get filterSubscribed => 'Abone Olunanlar';

  @override
  String get filterVisibility => 'Görünürlük';

  @override
  String get filterVisibilityPrivate => 'Gizli';

  @override
  String get filterVisibilityPublic => 'Herkese Açık';

  @override
  String get filterWatchableOn => 'İzlenebileceği Platformlar';

  @override
  String get followed => 'Takip Edilenler';

  @override
  String get followedAdd => 'Takip Et';

  @override
  String get followedRemove => 'Takibi Bırak';

  @override
  String get followers => 'Takipçiler';

  @override
  String get followingEachOther => 'Karşılıklı';

  @override
  String get followingThem => 'Takip Ediliyor';

  @override
  String get followingYou => 'Takipçi';

  @override
  String get forum => 'Forum';

  @override
  String get likes => 'Beğeniler';

  @override
  String get likesAdd => 'Beğen';

  @override
  String get likesRemove => 'Beğeniyi Kaldır';

  @override
  String get list => 'Listeler';

  @override
  String get listPreview => 'Önizleme';

  @override
  String get listSortAdded => 'Eklendi';

  @override
  String get listSortAiring => 'Yayınlanıyor';

  @override
  String get listSortCompleted => 'Tamamlandı';

  @override
  String get listSortProgress => 'İlerleme';

  @override
  String get listSortRating => 'Değerlendirme';

  @override
  String get listSortReleased => 'Yayınlandı';

  @override
  String get listSortRepeats => 'Tekrarlar';

  @override
  String get listSortScore => 'Puan';

  @override
  String get listSortStarted => 'Başlandı';

  @override
  String get listSortTitle => 'Başlık';

  @override
  String get listSortUpdated => 'Güncellendi';

  @override
  String get mangaCollection => 'Manga Koleksiyonu';

  @override
  String get media => 'Medya';

  @override
  String get mediaAdult => 'Yetişkin';

  @override
  String get mediaChapters => 'Bölümler';

  @override
  String get mediaDuration => 'Süre';

  @override
  String mediaEpisode(int episode) {
    return '$episode.Bölüm';
  }

  @override
  String mediaEpisodeIn(int episode, String timeUntilEpisode) {
    return '$timeUntilEpisode sonra Bölüm $episode';
  }

  @override
  String get mediaEpisodes => 'Bölümler';

  @override
  String mediaEpisodesBehind(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bölüm geride',
      one: '1 bölüm geride',
    );
    return '$_temp0';
  }

  @override
  String get mediaExternalLinks => 'Dış Bağlantılar';

  @override
  String get mediaFormat => 'Formatlar';

  @override
  String get mediaFormatManga => 'Manga';

  @override
  String get mediaFormatMovie => 'Film';

  @override
  String get mediaFormatMusic => 'Müzik';

  @override
  String get mediaFormatNovel => 'Roman';

  @override
  String get mediaFormatOna => 'ONA';

  @override
  String get mediaFormatOneShot => 'Tek Bölümlük';

  @override
  String get mediaFormatOva => 'OVA';

  @override
  String get mediaFormatSpecial => 'Özel';

  @override
  String get mediaFormatTv => 'TV';

  @override
  String get mediaFormatTvShort => 'Kısa TV';

  @override
  String mediaGenres(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Türler', one: 'Tür');
    return '$_temp0';
  }

  @override
  String get mediaHashtag => 'Etiket';

  @override
  String get mediaPopularity => 'Popülerlik';

  @override
  String mediaProducers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yapımcılar',
      one: 'Yapımcı',
    );
    return '$_temp0';
  }

  @override
  String get mediaRelationTypeAdaptation => 'Uyarlama';

  @override
  String get mediaRelationTypeAlternative => 'Alternatif';

  @override
  String get mediaRelationTypeCharacter => 'Karakter';

  @override
  String get mediaRelationTypeCompilation => 'Derleme';

  @override
  String get mediaRelationTypeContains => 'İçeren';

  @override
  String get mediaRelationTypeOther => 'Diğer';

  @override
  String get mediaRelationTypeParent => 'Ana Eser';

  @override
  String get mediaRelationTypePrequel => 'Öncesi';

  @override
  String get mediaRelationTypeSameUniverse => 'Aynı Evren';

  @override
  String get mediaRelationTypeSequel => 'Devamı';

  @override
  String get mediaRelationTypeSideStory => 'Yan Hikâye';

  @override
  String get mediaRelationTypeSource => 'Kaynak';

  @override
  String get mediaRelationTypeSpinOff => 'Yan Ürün';

  @override
  String get mediaRelationTypeSummary => 'Özet';

  @override
  String get mediaRelease => 'Yayın';

  @override
  String get mediaSeason => 'Sezon';

  @override
  String get mediaSeasonFall => 'Sonbahar';

  @override
  String get mediaSeasonSpring => 'İlkbahar';

  @override
  String get mediaSeasonSummer => 'Yaz';

  @override
  String get mediaSeasonWinter => 'Kış';

  @override
  String get mediaSortAddedFirst => 'İlk Eklenen';

  @override
  String get mediaSortAddedLast => 'Son Eklenen';

  @override
  String get mediaSortFavourites => 'Favoriler';

  @override
  String get mediaSortPopularity => 'Popülerlik';

  @override
  String get mediaSortReleasedEarliest => 'En Erken Yayınlanan';

  @override
  String get mediaSortReleasedLatest => 'En Son Yayınlanan';

  @override
  String get mediaSortScoreBest => 'Puan';

  @override
  String get mediaSortScoreWorst => 'En Düşük Puan';

  @override
  String get mediaSortTitleEnglish => 'İngilizce Başlık';

  @override
  String get mediaSortTitleNative => 'Orijinal Başlık';

  @override
  String get mediaSortTitleRomaji => 'Romaji Başlık';

  @override
  String get mediaSortTrending => 'Trend';

  @override
  String mediaSource(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kaynaklar',
      one: 'Kaynak',
    );
    return '$_temp0';
  }

  @override
  String get mediaSourceOriginal => 'Orijinal';

  @override
  String get mediaSourceAnime => 'Anime';

  @override
  String get mediaSourceComic => 'Çizgi Roman';

  @override
  String get mediaSourceDoujinshi => 'Doujinshi';

  @override
  String get mediaSourceGame => 'Oyun';

  @override
  String get mediaSourceLightNovel => 'Hafif Roman';

  @override
  String get mediaSourceLiveAction => 'Canlı Çekim';

  @override
  String get mediaSourceManga => 'Manga';

  @override
  String get mediaSourceMultimediaProject => 'Multimedya Projesi';

  @override
  String get mediaSourceNovel => 'Roman';

  @override
  String get mediaSourceOther => 'Diğer';

  @override
  String get mediaSourcePictureBook => 'Resimli Kitap';

  @override
  String get mediaSourceVideoGame => 'Video Oyunu';

  @override
  String get mediaSourceVisualNovel => 'Görsel Roman';

  @override
  String get mediaSourceWebNovel => 'Web Romanı';

  @override
  String mediaStatus(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Durumlar',
      one: 'Durum',
    );
    return '$_temp0';
  }

  @override
  String get mediaStatusCancelled => 'İptal Edildi';

  @override
  String get mediaStatusHiatus => 'Arada';

  @override
  String get mediaStatusReleased => 'Tamamlandı';

  @override
  String get mediaStatusReleasing => 'Yayınlanıyor';

  @override
  String get mediaStatusUnreleased => 'Henüz Yayınlanmadı';

  @override
  String get mediaScoreMean => 'Ortalama Puan';

  @override
  String get mediaScoreAverageWeighted => 'Ağırlıklı Ortalama Puan';

  @override
  String get mediaScoring3 => '3 İfade';

  @override
  String get mediaScoring5 => '5 Yıldız';

  @override
  String get mediaScoring10 => '10 Puan';

  @override
  String get mediaScoring100 => '100 Puan';

  @override
  String get mediaScoring10Decimal => '10 Ondalıklı Puan';

  @override
  String get mediaTitleEnglish => 'İngilizce';

  @override
  String get mediaTitleNative => 'Orijinal';

  @override
  String get mediaTitleRomaji => 'Romaji';

  @override
  String get mediaTitleSynonym => 'Eş Anlamlı';

  @override
  String get mediaType => 'Medya Türü';

  @override
  String get mediaTypeAnime => 'Anime';

  @override
  String get mediaTypeManga => 'Manga';

  @override
  String get mediaVolumes => 'Ciltler';

  @override
  String get numberDecrement => 'Azalt';

  @override
  String get numberIncrement => 'Artır';

  @override
  String numberMinimum(num number) {
    return 'En az $number';
  }

  @override
  String numberMaximum(num number) {
    return 'En fazla $number';
  }

  @override
  String get noEntries => 'Girdi yok';

  @override
  String get noResults => 'Sonuç yok';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notificationsFilterAll => 'Tümü';

  @override
  String get notificationsFilterReplies => 'Yanıtlar';

  @override
  String get notificationsFilterActivity => 'Etkinlik';

  @override
  String get notificationsFilterForum => 'Forum';

  @override
  String get notificationsFilterAiring => 'Yayınlanıyor';

  @override
  String get notificationsFilterFollows => 'Takip Edilenler';

  @override
  String get notificationsFilterMedia => 'Medya';

  @override
  String get notificationsTypeActivityLikes => 'Etkinlik beğenileri';

  @override
  String get notificationsTypeActivityMentions => 'Etkinlik bahsetmeleri';

  @override
  String get notificationsTypeActivityReplies => 'Etkinlik yanıtları';

  @override
  String get notificationsTypeActivityRepliesLikes => 'Etkinlik yanıtı beğenileri';

  @override
  String get notificationsTypeActivityRepliesSubscribed => 'Abone olunan etkinlik yanıtları';

  @override
  String get notificationsTypeFollows => 'Takip edilenler';

  @override
  String get notificationsTypeMediaAdditions => 'İlgili medya eklemeleri';

  @override
  String get notificationsTypeMediaAiring => 'Bölüm yayınları';

  @override
  String get notificationsTypeMediaChanges => 'Medya değişiklikleri';

  @override
  String get notificationsTypeMediaDeletions => 'Medya silinmeleri';

  @override
  String get notificationsTypeMediaMerges => 'Medya birleştirmeleri';

  @override
  String get notificationsTypeMessages => 'Mesajlar';

  @override
  String get notificationsTypeSubmissionsUpdatesCharacter => 'Karakter önerisi güncellemeleri';

  @override
  String get notificationsTypeSubmissionsUpdatesMedia => 'Medya önerisi güncellemeleri';

  @override
  String get notificationsTypeSubmissionsUpdatesStaff => 'Ekip önerisi güncellemeleri';

  @override
  String get notificationsTypeThreadComments => 'Başlık yorumları';

  @override
  String get notificationsTypeThreadCommentsLikes => 'Başlık yorumu beğenileri';

  @override
  String get notificationsTypeThreadLikes => 'Başlık beğenileri';

  @override
  String get notificationsTypeThreadMentions => 'Başlık bahsetmeleri';

  @override
  String get notificationsTypeThreadRepliesSubscribed => 'Abone olunan başlık yanıtları';

  @override
  String get overview => 'Genel Bakış';

  @override
  String get pagesNext => 'Sonraki Sayfa';

  @override
  String get pagesPrevious => 'Önceki Sayfa';

  @override
  String get personInfoAge => 'Yaş';

  @override
  String get personInfoBirth => 'Doğum Tarihi';

  @override
  String get personInfoBloodType => 'Kan Grubu';

  @override
  String get personInfoDeath => 'Ölüm Tarihi';

  @override
  String get personInfoGender => 'Cinsiyet';

  @override
  String get personInfoHomeTown => 'Memleket';

  @override
  String get personInfoNameAlternative => 'Alternatif';

  @override
  String get personInfoNameAlternativeSpoiler => 'Alternatif (Spoiler)';

  @override
  String get personInfoNameFull => 'Tam Ad';

  @override
  String get personInfoNameNative => 'Orijinal';

  @override
  String get personInfoYearsActive => 'Aktif Yıllar';

  @override
  String get postsAdd => 'Yeni Gönderi';

  @override
  String get postsAddMessage => 'Yeni Mesaj';

  @override
  String get postsLikes => 'Beğeniler';

  @override
  String get postsLocked => 'Kilitli';

  @override
  String get postsPinned => 'Sabitlenmiş';

  @override
  String get postsPinnedAdd => 'Sabitle';

  @override
  String get postsPinnedRemove => 'Sabitlemeyi Kaldır';

  @override
  String get postsPosted => 'gönderildi';

  @override
  String get postsReplied => 'yanıtlandı';

  @override
  String get postsReplies => 'Yanıtlar';

  @override
  String get postsRepliesAdd => 'Yanıtla';

  @override
  String postsRepliesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yanıt',
      one: '1 yanıt',
    );
    return '$_temp0';
  }

  @override
  String get postsViews => 'Görüntüleme';

  @override
  String get profile => 'Profil';

  @override
  String get random => 'Rastgele';

  @override
  String rankHighestRatedAllTime(int rank) {
    return '#$rank Tüm Zamanların En Yüksek Puanlısı';
  }

  @override
  String rankHighestRatedSeasonYear(int rank, int year, String season) {
    return '#$rank En Yüksek Puanlı $season $year';
  }

  @override
  String rankHighestRatedYear(int rank, int year) {
    return '#$rank En Yüksek Puanlı $year';
  }

  @override
  String rankMostPopularAllTime(Object rank) {
    return '#$rank Tüm Zamanların En Popüleri';
  }

  @override
  String rankMostPopularSeasonYear(int rank, int year, String season) {
    return '#$rank En Popüler $season $year';
  }

  @override
  String rankMostPopularYear(int rank, int year) {
    return '#$rank En Popüler $year';
  }

  @override
  String get recommendations => 'Öneriler';

  @override
  String get recommendationsSortHighestRated => 'En Yüksek Puanlı';

  @override
  String get recommendationsSortLowestRated => 'En Düşük Puanlı';

  @override
  String get recommendationsSortNewest => 'En Yeni';

  @override
  String get related => 'İlişkili';

  @override
  String get reviews => 'İncelemeler';

  @override
  String get reviewsBy => 'İnceleyen:';

  @override
  String reviewsOfBy(String mediaTitle, String userName) {
    return '$userName tarafından $mediaTitle incelemesi';
  }

  @override
  String get reviewsRating => 'İnceleme Puanı';

  @override
  String reviewsRatingValue(int positiveRating, int totalRating) {
    return '$positiveRating/$totalRating kullanıcı bu incelemeyi beğendi';
  }

  @override
  String get reviewsScore => 'İnceleme Puanı';

  @override
  String get reviewsSortHighestRated => 'En Yüksek Puanlı';

  @override
  String get reviewsSortLowestRated => 'En Düşük Puanlı';

  @override
  String get reviewsSortNewest => 'En Yeni';

  @override
  String get reviewsSortOldest => 'En Eski';

  @override
  String get roles => 'Roller';

  @override
  String get search => 'Ara';

  @override
  String get searchGlobally => 'Genel Arama Yapın';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingsAboutClearImageCache => 'Görsel Önbelleğini Temizle';

  @override
  String get settingsAboutDisclaimer => 'Resmî olmayan bir AniList uygulaması';

  @override
  String get settingsAboutDiscord => 'Discord';

  @override
  String get settingsAboutDonate => 'Bağış Yapın';

  @override
  String settingsAboutLastNotificationCheck(String lastJobTimestamp) {
    return 'Son bildirim kontrolü $lastJobTimestamp civarında yapıldı.';
  }

  @override
  String get settingsAboutPrivacyPolicy => 'Gizlilik Politikası';

  @override
  String get settingsAboutResetOptions => 'Seçenekleri Sıfırla';

  @override
  String get settingsAboutSourceCode => 'Kaynak Kodu';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsAppearanceModeDark => 'Karanlık';

  @override
  String get settingsAppearanceModeLight => 'Aydınlık';

  @override
  String get settingsAppearanceModeSystem => 'Sistem';

  @override
  String get settingsButtonOrientation => 'Düğme Yönü';

  @override
  String get settingsButtonOrientationAuto => 'Otomatik';

  @override
  String get settingsButtonOrientationLeft => 'Sol';

  @override
  String get settingsButtonOrientationRight => 'Sağ';

  @override
  String get settingsCollectionPreviews => 'Koleksiyon Önizlemeleri';

  @override
  String get settingsCollectionPreviewsAnime => 'Anime Koleksiyonu Önizlemesi';

  @override
  String get settingsCollectionPreviewsAnimeDescription =>
      'Yalnızca izlediğiniz/tekrar izlediğiniz animeleri yükleyin ve yüzen düğmeyle tüm koleksiyona genişletin';

  @override
  String get settingsCollectionPreviewsManga => 'Manga Koleksiyonu Önizlemesi';

  @override
  String get settingsCollectionPreviewsMangaDescription =>
      'Yalnızca okuduğunuz/tekrar okuduğunuz mangaları yükleyin ve yüzen düğmeyle tüm koleksiyona genişletin';

  @override
  String get settingsConfirmExit => 'Çıkışı Onayla';

  @override
  String get settingsDefaults => 'Varsayılanlar';

  @override
  String get settingsHighContrast => 'Yüksek Karşıtlık';

  @override
  String get settingsHighContrastDescription => 'Arı arka planlar ve kenarlıklı kartlar';

  @override
  String get settingsHomeTab => 'Ana Sayfa Sekmesi';

  @override
  String get settingsImageQuality => 'Görsel Kalitesi';

  @override
  String settingsListsCustomListsAnime(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Özel Anime Listeleri',
      one: 'Özel Anime Listesi',
    );
    return '$_temp0';
  }

  @override
  String settingsListsCustomListsManga(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Özel Manga Listeleri',
      one: 'Özel Manga Listesi',
    );
    return '$_temp0';
  }

  @override
  String get settingsListsDefaultSiteSort => 'Varsayılan Site Listesi Sıralaması';

  @override
  String get settingsListsScoringAdvanced => 'Gelişmiş Puanlama';

  @override
  String settingsListsScoringAdvancedSections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gelişmiş Puan Bölümleri',
      one: 'Gelişmiş Puan Bölümü',
    );
    return '$_temp0';
  }

  @override
  String get settingsListsScoringSystem => 'Puanlama Sistemi';

  @override
  String get settingsListsSplitAnime => 'Tamamlanan Animeleri Ayır';

  @override
  String get settingsListsSplitManga => 'Tamamlanan Mangaları Ayır';

  @override
  String get settingsMediaActivityMergeTime => 'Etkinlik Birleştirme Süresi';

  @override
  String get settingsMediaActivityMergeTimeAlways => 'Her Zaman';

  @override
  String settingsMediaActivityMergeTimeDays(int count) {
    return '$count Gün';
  }

  @override
  String settingsMediaActivityMergeTimeHours(int count) {
    return '$count Saat';
  }

  @override
  String settingsMediaActivityMergeTimeMinutes(int count) {
    return '$count Dakika';
  }

  @override
  String get settingsMediaActivityMergeTimeNever => 'Asla';

  @override
  String settingsMediaActivityMergeTimeWeeks(int count) {
    return '$count Hafta';
  }

  @override
  String get settingsMediaAdult => '18+ İçerik';

  @override
  String get settingsMediaAiringAnimeNotifications => 'Yayınlanan Anime Bildirimleri';

  @override
  String get settingsMediaPersonNaming => 'Karakter ve Ekip İsimleri';

  @override
  String get settingsMediaPersonNamingNative => 'Orijinal';

  @override
  String get settingsMediaPersonNamingRomaji => 'Romaji';

  @override
  String get settingsMediaPersonNamingRomajiWestern => 'Romaji, Batı Sıralaması';

  @override
  String get settingsMediaTitleLanguage => 'Başlık Dili';

  @override
  String get settingsMediaTitleLanguageEnglish => 'İngilizce';

  @override
  String get settingsMediaTitleLanguageNative => 'Orijinal';

  @override
  String get settingsMediaTitleLanguageRomaji => 'Romaji';

  @override
  String settingsSocialActivityCreation(String listStatus) {
    return '$listStatus etkinlikleri oluşturun';
  }

  @override
  String get settingsSocialLimitMessages => 'Mesajları Sınırla';

  @override
  String get settingsSocialLimitMessagesDescription =>
      'Yalnızca takip ettiğim kullanıcılar bana mesaj gönderebilir';

  @override
  String get settingsTabAbout => 'Hakkında';

  @override
  String get settingsTabApp => 'Uygulama';

  @override
  String get settingsTabContent => 'İçerik';

  @override
  String get settingsViewLayout => 'Görünüm Düzenleri';

  @override
  String get settingsViewLayoutDetailed => 'Ayrıntılı';

  @override
  String get settingsViewLayoutDiscover => 'Keşif Görünümü';

  @override
  String get settingsViewLayoutCollection => 'Koleksiyon Görünümü';

  @override
  String get settingsViewLayoutCollectionPreview => 'Koleksiyon Önizleme Görünümü';

  @override
  String get settingsViewLayoutSimple => 'Sade';

  @override
  String get social => 'Sosyal';

  @override
  String get staff => 'Ekip';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get statisticsAnime => 'Anime İstatistikleri';

  @override
  String get statisticsChaptersRead => 'Okunan Bölüm Sayısı';

  @override
  String get statisticsDaysWatched => 'İzlenen Gün Sayısı';

  @override
  String get statisticsDistributionCountry => 'Ülke Dağılımı';

  @override
  String get statisticsDistributionFormat => 'Format Dağılımı';

  @override
  String get statisticsDistributionScore => 'Puan Dağılımı';

  @override
  String get statisticsDistributionStatus => 'Durum Dağılımı';

  @override
  String get statisticsEpisodesWatched => 'İzlenen Bölüm Sayısı';

  @override
  String get statisticsHours => 'Saat';

  @override
  String get statisticsManga => 'Manga İstatistikleri';

  @override
  String get statisticsStandardDeviation => 'Standart Sapma';

  @override
  String get statisticsTitles => 'Başlıklar';

  @override
  String get statisticsTotalAnime => 'Toplam Anime';

  @override
  String get statisticsTotalManga => 'Toplam Manga';

  @override
  String get statisticsVolumesRead => 'Okunan Cilt Sayısı';

  @override
  String studios(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stüdyo',
      one: 'Stüdyo',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionsAdd => 'Abone Ol';

  @override
  String get subscriptionsRemove => 'Abonelikten Çık';

  @override
  String tags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Etiketler',
      one: 'Etiket',
    );
    return '$_temp0';
  }

  @override
  String get themeCaramel => 'Karamel';

  @override
  String get themeForest => 'Orman';

  @override
  String get themeLavender => 'Lavanta';

  @override
  String get themeMint => 'Nane';

  @override
  String get themeMustard => 'Hardal';

  @override
  String get themeNavy => 'Lacivert';

  @override
  String get themeWine => 'Bordo';

  @override
  String get threads => 'Başlıklar';

  @override
  String get users => 'Kullanıcılar';

  @override
  String usersJoinedAt(String at) {
    return '$at tarihinde katıldı';
  }
}
