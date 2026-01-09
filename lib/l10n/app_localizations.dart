import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tawfir Energy'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @slogan.
  ///
  /// In en, this message translates to:
  /// **'Consume smartly, without going broke'**
  String get slogan;

  /// No description provided for @requestFreeStudy.
  ///
  /// In en, this message translates to:
  /// **'Request a free study'**
  String get requestFreeStudy;

  /// No description provided for @ourServices.
  ///
  /// In en, this message translates to:
  /// **'Our Services'**
  String get ourServices;

  /// No description provided for @servicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete solar solutions for sustainable savings.'**
  String get servicesSubtitle;

  /// No description provided for @studyQuote.
  ///
  /// In en, this message translates to:
  /// **'Study & Quote\nFree'**
  String get studyQuote;

  /// No description provided for @studyQuoteDescription.
  ///
  /// In en, this message translates to:
  /// **'Analysis of your consumption and free estimate of your solar installation.'**
  String get studyQuoteDescription;

  /// No description provided for @installation.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get installation;

  /// No description provided for @installationDescription.
  ///
  /// In en, this message translates to:
  /// **'Professional installation compliant with standards for individuals and businesses.'**
  String get installationDescription;

  /// No description provided for @solarCalculator.
  ///
  /// In en, this message translates to:
  /// **'Solar Calculator'**
  String get solarCalculator;

  /// No description provided for @solarCalculatorDescription.
  ///
  /// In en, this message translates to:
  /// **'Estimate your installation and savings in a few clicks.'**
  String get solarCalculatorDescription;

  /// No description provided for @maintenanceRepair.
  ///
  /// In en, this message translates to:
  /// **'Maintenance &\nRepair'**
  String get maintenanceRepair;

  /// No description provided for @maintenanceRepairDescription.
  ///
  /// In en, this message translates to:
  /// **'Maintenance, diagnosis and repair of your existing solar systems.'**
  String get maintenanceRepairDescription;

  /// No description provided for @certifiedTechnicians.
  ///
  /// In en, this message translates to:
  /// **'Certified\nTechnicians'**
  String get certifiedTechnicians;

  /// No description provided for @certifiedTechniciansDescription.
  ///
  /// In en, this message translates to:
  /// **'Intervention by qualified and certified technicians throughout Morocco.'**
  String get certifiedTechniciansDescription;

  /// No description provided for @proSpaceInfo.
  ///
  /// In en, this message translates to:
  /// **'Pro Space: Reserved for partner companies and technicians'**
  String get proSpaceInfo;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @proSpace.
  ///
  /// In en, this message translates to:
  /// **'Pro Space'**
  String get proSpace;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @chatComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Chat will be available soon'**
  String get chatComingSoon;

  /// No description provided for @shopComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Shop will be available soon'**
  String get shopComingSoon;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @connectToAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect to your account'**
  String get connectToAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @joinToday.
  ///
  /// In en, this message translates to:
  /// **'Join Tawfir Energy today'**
  String get joinToday;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get enterConfirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @otherSettingsComing.
  ///
  /// In en, this message translates to:
  /// **'Other settings coming soon...'**
  String get otherSettingsComing;

  /// No description provided for @becomePartner.
  ///
  /// In en, this message translates to:
  /// **'Become Partner'**
  String get becomePartner;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @partnerDescription.
  ///
  /// In en, this message translates to:
  /// **'For certified solar energy companies'**
  String get partnerDescription;

  /// No description provided for @becomeTechnician.
  ///
  /// In en, this message translates to:
  /// **'Become Technician'**
  String get becomeTechnician;

  /// No description provided for @technicianDescription.
  ///
  /// In en, this message translates to:
  /// **'For certified technicians in maintenance and installation'**
  String get technicianDescription;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @billAmount.
  ///
  /// In en, this message translates to:
  /// **'Bill Amount (DH)'**
  String get billAmount;

  /// No description provided for @monthlyBillAmount.
  ///
  /// In en, this message translates to:
  /// **'Monthly bill amount (DH) *'**
  String get monthlyBillAmount;

  /// No description provided for @enterBillAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter your bill amount'**
  String get enterBillAmount;

  /// No description provided for @systemType.
  ///
  /// In en, this message translates to:
  /// **'System Type'**
  String get systemType;

  /// No description provided for @selectSystemType.
  ///
  /// In en, this message translates to:
  /// **'Select system type'**
  String get selectSystemType;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get selectType;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @selectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select your region'**
  String get selectRegion;

  /// No description provided for @selectRegionHint.
  ///
  /// In en, this message translates to:
  /// **'Select a region'**
  String get selectRegionHint;

  /// No description provided for @usageType.
  ///
  /// In en, this message translates to:
  /// **'Usage Type'**
  String get usageType;

  /// No description provided for @selectUsageType.
  ///
  /// In en, this message translates to:
  /// **'Select usage type'**
  String get selectUsageType;

  /// No description provided for @panelPower.
  ///
  /// In en, this message translates to:
  /// **'Panel Power'**
  String get panelPower;

  /// No description provided for @panelPowerW.
  ///
  /// In en, this message translates to:
  /// **'Panel Power (W)'**
  String get panelPowerW;

  /// No description provided for @selectPanelPower.
  ///
  /// In en, this message translates to:
  /// **'Select panel power'**
  String get selectPanelPower;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get fillAllFields;

  /// No description provided for @fillThisField.
  ///
  /// In en, this message translates to:
  /// **'Please fill this field'**
  String get fillThisField;

  /// No description provided for @invalidBillAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid bill amount'**
  String get invalidBillAmount;

  /// No description provided for @errorLoadingRegions.
  ///
  /// In en, this message translates to:
  /// **'Error loading regions'**
  String get errorLoadingRegions;

  /// No description provided for @errorCalculating.
  ///
  /// In en, this message translates to:
  /// **'Error calculating'**
  String get errorCalculating;

  /// No description provided for @onGrid.
  ///
  /// In en, this message translates to:
  /// **'ON-GRID'**
  String get onGrid;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'HYBRID'**
  String get hybrid;

  /// No description provided for @offGrid.
  ///
  /// In en, this message translates to:
  /// **'OFF-GRID'**
  String get offGrid;

  /// No description provided for @house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get house;

  /// No description provided for @commerce.
  ///
  /// In en, this message translates to:
  /// **'Commerce'**
  String get commerce;

  /// No description provided for @industry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industry;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @firebaseNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Error: Firebase is not initialized. Please configure Firebase.'**
  String get firebaseNotInitialized;

  /// No description provided for @errorSending.
  ///
  /// In en, this message translates to:
  /// **'Error sending'**
  String get errorSending;

  /// No description provided for @errorDetails.
  ///
  /// In en, this message translates to:
  /// **'Error details'**
  String get errorDetails;

  /// No description provided for @newQuoteRequest.
  ///
  /// In en, this message translates to:
  /// **'New quote request'**
  String get newQuoteRequest;

  /// No description provided for @quoteRequest.
  ///
  /// In en, this message translates to:
  /// **'Quote Request'**
  String get quoteRequest;

  /// No description provided for @consumption.
  ///
  /// In en, this message translates to:
  /// **'Consumption'**
  String get consumption;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get useMyLocation;

  /// No description provided for @gpsLocation.
  ///
  /// In en, this message translates to:
  /// **'GPS Location'**
  String get gpsLocation;

  /// No description provided for @clickUseLocation.
  ///
  /// In en, this message translates to:
  /// **'Click on \"Use my location\"'**
  String get clickUseLocation;

  /// No description provided for @gpsCaptured.
  ///
  /// In en, this message translates to:
  /// **'GPS location captured'**
  String get gpsCaptured;

  /// No description provided for @gpsDetectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'GPS location detected successfully'**
  String get gpsDetectedSuccess;

  /// No description provided for @gpsDetectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to detect your location. Please verify that location services are enabled and you have granted the necessary permissions.'**
  String get gpsDetectionFailed;

  /// No description provided for @gpsError.
  ///
  /// In en, this message translates to:
  /// **'Error detecting location'**
  String get gpsError;

  /// No description provided for @uploadDisabled.
  ///
  /// In en, this message translates to:
  /// **'Upload temporarily disabled. Feature will be activated soon 👍'**
  String get uploadDisabled;

  /// No description provided for @chooseBill.
  ///
  /// In en, this message translates to:
  /// **'Choose a bill'**
  String get chooseBill;

  /// No description provided for @financingOption.
  ///
  /// In en, this message translates to:
  /// **'Financing Option'**
  String get financingOption;

  /// No description provided for @accessFinancingForm.
  ///
  /// In en, this message translates to:
  /// **'Access financing form'**
  String get accessFinancingForm;

  /// No description provided for @maintenanceRequest.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Request'**
  String get maintenanceRequest;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Ahmed Benali'**
  String get nameHint;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: +212 612 345 678'**
  String get phoneHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Casablanca'**
  String get cityHint;

  /// No description provided for @describeProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem'**
  String get describeProblem;

  /// No description provided for @describeProblemHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem you are experiencing...'**
  String get describeProblemHint;

  /// No description provided for @urgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get urgency;

  /// No description provided for @selectUrgency.
  ///
  /// In en, this message translates to:
  /// **'Select urgency level'**
  String get selectUrgency;

  /// No description provided for @urgencyLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get urgencyLow;

  /// No description provided for @urgencyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get urgencyNormal;

  /// No description provided for @urgencyHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get urgencyHigh;

  /// No description provided for @urgencyUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgencyUrgent;

  /// No description provided for @addPhotoVideo.
  ///
  /// In en, this message translates to:
  /// **'Add photo/video'**
  String get addPhotoVideo;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @mediaAdded.
  ///
  /// In en, this message translates to:
  /// **'Media added (feature coming soon)'**
  String get mediaAdded;

  /// No description provided for @callFeatureComing.
  ///
  /// In en, this message translates to:
  /// **'Call feature coming soon'**
  String get callFeatureComing;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @companyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Solar Energy Maroc'**
  String get companyNameHint;

  /// No description provided for @cityHintPartner.
  ///
  /// In en, this message translates to:
  /// **'Ex: Casablanca'**
  String get cityHintPartner;

  /// No description provided for @phoneHintPartner.
  ///
  /// In en, this message translates to:
  /// **'Ex: +212 612 345 678'**
  String get phoneHintPartner;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: contact@entreprise.com'**
  String get emailHint;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @specialtyHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Solar installation, Maintenance...'**
  String get specialtyHint;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @amountMustBeGreater.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 50 DH'**
  String get amountMustBeGreater;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request Sent'**
  String get requestSent;

  /// No description provided for @requestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your intervention request has been sent successfully.'**
  String get requestSentSuccess;

  /// No description provided for @detectMyPosition.
  ///
  /// In en, this message translates to:
  /// **'Detect my position'**
  String get detectMyPosition;

  /// No description provided for @addressGps.
  ///
  /// In en, this message translates to:
  /// **'Address / GPS Coordinates *'**
  String get addressGps;

  /// No description provided for @captureGpsPosition.
  ///
  /// In en, this message translates to:
  /// **'Please capture your GPS position'**
  String get captureGpsPosition;

  /// No description provided for @callTechnician.
  ///
  /// In en, this message translates to:
  /// **'Call technician'**
  String get callTechnician;

  /// No description provided for @interventionRequest.
  ///
  /// In en, this message translates to:
  /// **'Intervention Request'**
  String get interventionRequest;

  /// No description provided for @systemTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'System Type'**
  String get systemTypeLabel;

  /// No description provided for @locationType.
  ///
  /// In en, this message translates to:
  /// **'Location Type'**
  String get locationType;

  /// No description provided for @describeBriefly.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe your request...'**
  String get describeBriefly;

  /// No description provided for @photosOptional.
  ///
  /// In en, this message translates to:
  /// **'Photos (optional, max 3)'**
  String get photosOptional;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhoto;

  /// No description provided for @maxPhotosAllowed.
  ///
  /// In en, this message translates to:
  /// **'Maximum 3 photos allowed'**
  String get maxPhotosAllowed;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added (feature coming soon)'**
  String get photoAdded;

  /// No description provided for @uploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload documents'**
  String get uploadDocuments;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents (certificates, licenses)'**
  String get documents;

  /// No description provided for @certificatesDocuments.
  ///
  /// In en, this message translates to:
  /// **'Certificates and documents'**
  String get certificatesDocuments;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @addAdditionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Add additional information...'**
  String get addAdditionalInfo;

  /// No description provided for @gpsCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Ex: 33.5731, -7.5898'**
  String get gpsCoordinates;

  /// No description provided for @emailExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: ahmed@example.com'**
  String get emailExample;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get fullNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone *'**
  String get phoneLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get cityLabel;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterYourName;

  /// No description provided for @enterYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get enterYourPhone;

  /// No description provided for @enterYourCity.
  ///
  /// In en, this message translates to:
  /// **'Please enter your city'**
  String get enterYourCity;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter company name'**
  String get enterCompanyName;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @createRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get createRequest;

  /// No description provided for @requestQuote.
  ///
  /// In en, this message translates to:
  /// **'Request Quote'**
  String get requestQuote;

  /// No description provided for @descriptionShort.
  ///
  /// In en, this message translates to:
  /// **'Short Description'**
  String get descriptionShort;

  /// No description provided for @gpsOptional.
  ///
  /// In en, this message translates to:
  /// **'GPS (optional)'**
  String get gpsOptional;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @calculationResult.
  ///
  /// In en, this message translates to:
  /// **'Calculation Result'**
  String get calculationResult;

  /// No description provided for @calculationResults.
  ///
  /// In en, this message translates to:
  /// **'Calculation Results'**
  String get calculationResults;

  /// No description provided for @estimatedConsumption.
  ///
  /// In en, this message translates to:
  /// **'Estimated consumption'**
  String get estimatedConsumption;

  /// No description provided for @recommendedSystemPower.
  ///
  /// In en, this message translates to:
  /// **'Recommended system power'**
  String get recommendedSystemPower;

  /// No description provided for @numberOfPanels.
  ///
  /// In en, this message translates to:
  /// **'Number of panels'**
  String get numberOfPanels;

  /// No description provided for @savingRate.
  ///
  /// In en, this message translates to:
  /// **'Saving rate'**
  String get savingRate;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @tenYears.
  ///
  /// In en, this message translates to:
  /// **'10 years'**
  String get tenYears;

  /// No description provided for @twentyYears.
  ///
  /// In en, this message translates to:
  /// **'20 years'**
  String get twentyYears;

  /// No description provided for @basedOnSunHours.
  ///
  /// In en, this message translates to:
  /// **'Based on sun hours of {month} – {region}'**
  String basedOnSunHours(String month, String region);

  /// No description provided for @estimatedResults.
  ///
  /// In en, this message translates to:
  /// **'Estimated results — final quote after technical study'**
  String get estimatedResults;

  /// No description provided for @requestDevis.
  ///
  /// In en, this message translates to:
  /// **'Request a Quote'**
  String get requestDevis;

  /// No description provided for @requestPumpingDevis.
  ///
  /// In en, this message translates to:
  /// **'Request Pumping Quote'**
  String get requestPumpingDevis;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height (H)'**
  String get height;

  /// No description provided for @pumpPower.
  ///
  /// In en, this message translates to:
  /// **'Pump power'**
  String get pumpPower;

  /// No description provided for @pvPower.
  ///
  /// In en, this message translates to:
  /// **'PV power'**
  String get pvPower;

  /// No description provided for @noMediaSelected.
  ///
  /// In en, this message translates to:
  /// **'No media selected'**
  String get noMediaSelected;

  /// No description provided for @noDocumentSelected.
  ///
  /// In en, this message translates to:
  /// **'No document selected'**
  String get noDocumentSelected;

  /// No description provided for @noPhotoSelected.
  ///
  /// In en, this message translates to:
  /// **'No photo selected'**
  String get noPhotoSelected;

  /// No description provided for @requestCreated.
  ///
  /// In en, this message translates to:
  /// **'Request created'**
  String get requestCreated;

  /// No description provided for @demandSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get demandSent;

  /// No description provided for @devisRequestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your quote request has been sent successfully.'**
  String get devisRequestSentSuccess;

  /// No description provided for @pumpingDevisSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Pumping quote request sent successfully'**
  String get pumpingDevisSentSuccess;

  /// No description provided for @registrationSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your registration request has been sent successfully. We will contact you soon.'**
  String get registrationSentSuccess;

  /// No description provided for @partnershipSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your partnership request has been sent successfully. We will contact you soon.'**
  String get partnershipSentSuccess;

  /// No description provided for @whatsAppFeatureComing.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp feature coming soon'**
  String get whatsAppFeatureComing;

  /// No description provided for @whatsAppContact.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Contact'**
  String get whatsAppContact;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @technicalData.
  ///
  /// In en, this message translates to:
  /// **'Technical data (read-only)'**
  String get technicalData;

  /// No description provided for @regionCode.
  ///
  /// In en, this message translates to:
  /// **'Region code'**
  String get regionCode;

  /// No description provided for @consumptionKwhMonth.
  ///
  /// In en, this message translates to:
  /// **'Consumption (kWh/month)'**
  String get consumptionKwhMonth;

  /// No description provided for @recommendedPower.
  ///
  /// In en, this message translates to:
  /// **'Recommended power'**
  String get recommendedPower;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactInfo;

  /// No description provided for @enterConsumption.
  ///
  /// In en, this message translates to:
  /// **'Please enter consumption'**
  String get enterConsumption;

  /// No description provided for @describeProblemRequired.
  ///
  /// In en, this message translates to:
  /// **'Please describe the problem'**
  String get describeProblemRequired;

  /// No description provided for @enterCityOrAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter your city or address'**
  String get enterCityOrAddress;

  /// No description provided for @addPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'Add photo ({count}/3)'**
  String addPhotoCount(int count);

  /// No description provided for @enterSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your specialty'**
  String get enterSpecialty;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @enterKwh.
  ///
  /// In en, this message translates to:
  /// **'Enter kWh'**
  String get enterKwh;

  /// No description provided for @uploadBill.
  ///
  /// In en, this message translates to:
  /// **'Upload bill'**
  String get uploadBill;

  /// No description provided for @consumptionKwh.
  ///
  /// In en, this message translates to:
  /// **'Consumption (kWh)'**
  String get consumptionKwh;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @gpsPositionCaptured.
  ///
  /// In en, this message translates to:
  /// **'GPS position captured'**
  String get gpsPositionCaptured;

  /// No description provided for @onGridSystem.
  ///
  /// In en, this message translates to:
  /// **'On-grid'**
  String get onGridSystem;

  /// No description provided for @offGridSystem.
  ///
  /// In en, this message translates to:
  /// **'Off-grid'**
  String get offGridSystem;

  /// No description provided for @hybridSystem.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybridSystem;

  /// No description provided for @pumpSystem.
  ///
  /// In en, this message translates to:
  /// **'Pump'**
  String get pumpSystem;

  /// No description provided for @homeLocation.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeLocation;

  /// No description provided for @businessLocation.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get businessLocation;

  /// No description provided for @farmLocation.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get farmLocation;

  /// No description provided for @otherLocation.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherLocation;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @pumpingSolar.
  ///
  /// In en, this message translates to:
  /// **'Solar Pumping'**
  String get pumpingSolar;

  /// No description provided for @pumpingSolarDescription.
  ///
  /// In en, this message translates to:
  /// **'Calculate your solar pumping system with precision.'**
  String get pumpingSolarDescription;

  /// No description provided for @pumpingSolarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated results based on your region and actual needs.'**
  String get pumpingSolarSubtitle;

  /// No description provided for @step1ChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'Step 1 — Choose calculation method'**
  String get step1ChooseMethod;

  /// No description provided for @step2EnterInfo.
  ///
  /// In en, this message translates to:
  /// **'Step 2 — Enter information'**
  String get step2EnterInfo;

  /// No description provided for @step3Calculate.
  ///
  /// In en, this message translates to:
  /// **'Step 3 — Calculate results'**
  String get step3Calculate;

  /// No description provided for @modeFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'I already have the flow (Q)'**
  String get modeFlowTitle;

  /// No description provided for @modeFlowDescription.
  ///
  /// In en, this message translates to:
  /// **'Use this mode if you already know your pump\'s flow rate.'**
  String get modeFlowDescription;

  /// No description provided for @modeAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know the flow (agricultural area)'**
  String get modeAreaTitle;

  /// No description provided for @modeAreaDescription.
  ///
  /// In en, this message translates to:
  /// **'Ideal for farmers who know the area and crop type.'**
  String get modeAreaDescription;

  /// No description provided for @modeTankTitle.
  ///
  /// In en, this message translates to:
  /// **'I have a tank'**
  String get modeTankTitle;

  /// No description provided for @modeTankDescription.
  ///
  /// In en, this message translates to:
  /// **'Use this mode if you fill a water tower or cistern.'**
  String get modeTankDescription;

  /// No description provided for @currentEnergySource.
  ///
  /// In en, this message translates to:
  /// **'Current energy source'**
  String get currentEnergySource;

  /// No description provided for @selectCurrentEnergySource.
  ///
  /// In en, this message translates to:
  /// **'Please select your current energy source'**
  String get selectCurrentEnergySource;

  /// No description provided for @selectSource.
  ///
  /// In en, this message translates to:
  /// **'Select a source'**
  String get selectSource;

  /// No description provided for @electricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricity;

  /// No description provided for @diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get diesel;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'I don\'t know'**
  String get unknown;

  /// No description provided for @selectCalculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Please select a calculation method'**
  String get selectCalculationMethod;

  /// No description provided for @selectYourRegion.
  ///
  /// In en, this message translates to:
  /// **'Please select your region'**
  String get selectYourRegion;

  /// No description provided for @selectYourEnergySource.
  ///
  /// In en, this message translates to:
  /// **'Please select your current energy source'**
  String get selectYourEnergySource;

  /// No description provided for @calculationError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during calculation. Please check your data and try again.'**
  String get calculationError;

  /// No description provided for @flow.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get flow;

  /// No description provided for @enterFlow.
  ///
  /// In en, this message translates to:
  /// **'Please enter the flow'**
  String get enterFlow;

  /// No description provided for @flowMustBeGreater.
  ///
  /// In en, this message translates to:
  /// **'Flow must be greater than 0'**
  String get flowMustBeGreater;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @flowUnitM3h.
  ///
  /// In en, this message translates to:
  /// **'m³/h'**
  String get flowUnitM3h;

  /// No description provided for @flowUnitLmin.
  ///
  /// In en, this message translates to:
  /// **'L/min'**
  String get flowUnitLmin;

  /// No description provided for @headMeters.
  ///
  /// In en, this message translates to:
  /// **'Head (m)'**
  String get headMeters;

  /// No description provided for @operatingHoursPerDay.
  ///
  /// In en, this message translates to:
  /// **'Operating hours per day'**
  String get operatingHoursPerDay;

  /// No description provided for @surface.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get surface;

  /// No description provided for @enterSurface.
  ///
  /// In en, this message translates to:
  /// **'Please enter the surface'**
  String get enterSurface;

  /// No description provided for @surfaceMustBeGreater.
  ///
  /// In en, this message translates to:
  /// **'Surface must be greater than 0'**
  String get surfaceMustBeGreater;

  /// No description provided for @areaUnitM2.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get areaUnitM2;

  /// No description provided for @areaUnitHa.
  ///
  /// In en, this message translates to:
  /// **'ha'**
  String get areaUnitHa;

  /// No description provided for @cropType.
  ///
  /// In en, this message translates to:
  /// **'Crop type'**
  String get cropType;

  /// No description provided for @selectCropType.
  ///
  /// In en, this message translates to:
  /// **'Select a crop'**
  String get selectCropType;

  /// No description provided for @irrigationType.
  ///
  /// In en, this message translates to:
  /// **'Irrigation type'**
  String get irrigationType;

  /// No description provided for @selectIrrigationType.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get selectIrrigationType;

  /// No description provided for @tankVolume.
  ///
  /// In en, this message translates to:
  /// **'Tank volume (m³)'**
  String get tankVolume;

  /// No description provided for @fillTime.
  ///
  /// In en, this message translates to:
  /// **'Fill time (hours)'**
  String get fillTime;

  /// No description provided for @wellDepth.
  ///
  /// In en, this message translates to:
  /// **'Well depth (m)'**
  String get wellDepth;

  /// No description provided for @tankHeight.
  ///
  /// In en, this message translates to:
  /// **'Tank height (m)'**
  String get tankHeight;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @valueMustBeGreater.
  ///
  /// In en, this message translates to:
  /// **'Value must be greater than 0'**
  String get valueMustBeGreater;

  /// No description provided for @invalidValues.
  ///
  /// In en, this message translates to:
  /// **'Invalid values'**
  String get invalidValues;

  /// No description provided for @systemTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'System Type *'**
  String get systemTypeRequired;

  /// No description provided for @selectSystemTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select a system type'**
  String get selectSystemTypeHint;

  /// No description provided for @pumpingSolarSystem.
  ///
  /// In en, this message translates to:
  /// **'POMPAGE SOLAIRE'**
  String get pumpingSolarSystem;

  /// No description provided for @billAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Bill amount (DH) *'**
  String get billAmountLabel;

  /// No description provided for @billAmountExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: 500'**
  String get billAmountExample;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @usageTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Usage Type'**
  String get usageTypeLabel;

  /// No description provided for @selectUsageTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get selectUsageTypeHint;

  /// No description provided for @batteryCapacity.
  ///
  /// In en, this message translates to:
  /// **'Battery capacity (kWh)'**
  String get batteryCapacity;

  /// No description provided for @batteryCapacityRequired.
  ///
  /// In en, this message translates to:
  /// **'Battery capacity (kWh) *'**
  String get batteryCapacityRequired;

  /// No description provided for @selectBatteryCapacity.
  ///
  /// In en, this message translates to:
  /// **'Select a capacity'**
  String get selectBatteryCapacity;

  /// No description provided for @consumptionPerDay.
  ///
  /// In en, this message translates to:
  /// **'Consumption (kWh/day) *'**
  String get consumptionPerDay;

  /// No description provided for @consumptionExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: 10'**
  String get consumptionExample;

  /// No description provided for @consumptionMustBeGreater.
  ///
  /// In en, this message translates to:
  /// **'Consumption must be greater than 0'**
  String get consumptionMustBeGreater;

  /// No description provided for @autonomyDays.
  ///
  /// In en, this message translates to:
  /// **'Autonomy days *'**
  String get autonomyDays;

  /// No description provided for @selectAutonomy.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectAutonomy;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @flowLabel.
  ///
  /// In en, this message translates to:
  /// **'Flow *'**
  String get flowLabel;

  /// No description provided for @flowExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: 10'**
  String get flowExample;

  /// No description provided for @flowMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Flow must be greater than 0'**
  String get flowMustBeGreaterThanZero;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit *'**
  String get unitLabel;

  /// No description provided for @unitHint.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitHint;

  /// No description provided for @headMetersLabel.
  ///
  /// In en, this message translates to:
  /// **'Head (m) *'**
  String get headMetersLabel;

  /// No description provided for @headExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: 50'**
  String get headExample;

  /// No description provided for @headMustBeGreater.
  ///
  /// In en, this message translates to:
  /// **'Head must be greater than 0'**
  String get headMustBeGreater;

  /// No description provided for @operatingHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Operating hours per day *'**
  String get operatingHoursLabel;

  /// No description provided for @hoursExample.
  ///
  /// In en, this message translates to:
  /// **'Ex: 8'**
  String get hoursExample;

  /// No description provided for @hoursMustBeGreater.
  ///
  /// In en, this message translates to:
  /// **'Hours must be greater than 0'**
  String get hoursMustBeGreater;

  /// No description provided for @pumpTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Pump type *'**
  String get pumpTypeLabel;

  /// No description provided for @selectPumpTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get selectPumpTypeHint;

  /// No description provided for @selectSystemTypeError.
  ///
  /// In en, this message translates to:
  /// **'Please select a system type'**
  String get selectSystemTypeError;

  /// No description provided for @selectRegionError.
  ///
  /// In en, this message translates to:
  /// **'Please select a region'**
  String get selectRegionError;

  /// No description provided for @fillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get fillAllRequiredFields;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @invalidConsumption.
  ///
  /// In en, this message translates to:
  /// **'Invalid consumption'**
  String get invalidConsumption;

  /// No description provided for @batteryAndAutonomyRequired.
  ///
  /// In en, this message translates to:
  /// **'Battery and autonomy required'**
  String get batteryAndAutonomyRequired;

  /// No description provided for @invalidSystemType.
  ///
  /// In en, this message translates to:
  /// **'Invalid system type'**
  String get invalidSystemType;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @resultOnGrid.
  ///
  /// In en, this message translates to:
  /// **'ON-GRID Result'**
  String get resultOnGrid;

  /// No description provided for @resultHybrid.
  ///
  /// In en, this message translates to:
  /// **'HYBRID Result'**
  String get resultHybrid;

  /// No description provided for @resultOffGrid.
  ///
  /// In en, this message translates to:
  /// **'OFF-GRID Result'**
  String get resultOffGrid;

  /// No description provided for @resultPumping.
  ///
  /// In en, this message translates to:
  /// **'Solar Pumping Result'**
  String get resultPumping;

  /// No description provided for @calculationResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculation Results'**
  String get calculationResultsTitle;

  /// No description provided for @estimatedConsumptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated consumption'**
  String get estimatedConsumptionLabel;

  /// No description provided for @recommendedSystemPowerLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended system power'**
  String get recommendedSystemPowerLabel;

  /// No description provided for @numberOfPanelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of panels'**
  String get numberOfPanelsLabel;

  /// No description provided for @savingRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving rate'**
  String get savingRateLabel;

  /// No description provided for @savingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savingsTitle;

  /// No description provided for @monthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyLabel;

  /// No description provided for @yearlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearlyLabel;

  /// No description provided for @tenYearsLabel.
  ///
  /// In en, this message translates to:
  /// **'10 years'**
  String get tenYearsLabel;

  /// No description provided for @twentyYearsLabel.
  ///
  /// In en, this message translates to:
  /// **'20 years'**
  String get twentyYearsLabel;

  /// No description provided for @basedOnSunHoursInfo.
  ///
  /// In en, this message translates to:
  /// **'Based on {hours}h of sun per day - {region}'**
  String basedOnSunHoursInfo(String hours, String region);

  /// No description provided for @dailyConsumption.
  ///
  /// In en, this message translates to:
  /// **'Daily consumption'**
  String get dailyConsumption;

  /// No description provided for @batteryCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery capacity'**
  String get batteryCapacityLabel;

  /// No description provided for @autonomyLabel.
  ///
  /// In en, this message translates to:
  /// **'Autonomy'**
  String get autonomyLabel;

  /// No description provided for @batteryCoverage.
  ///
  /// In en, this message translates to:
  /// **'Battery coverage'**
  String get batteryCoverage;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @flowValue.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get flowValue;

  /// No description provided for @headMetersValue.
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get headMetersValue;

  /// No description provided for @pumpPowerLabel.
  ///
  /// In en, this message translates to:
  /// **'Pump power'**
  String get pumpPowerLabel;

  /// No description provided for @pvPowerLabel.
  ///
  /// In en, this message translates to:
  /// **'PV power'**
  String get pvPowerLabel;

  /// No description provided for @pumpTypeValue.
  ///
  /// In en, this message translates to:
  /// **'Pump type'**
  String get pumpTypeValue;

  /// No description provided for @requestPumpingQuote.
  ///
  /// In en, this message translates to:
  /// **'Request pumping quote'**
  String get requestPumpingQuote;

  /// No description provided for @selectHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectHint;

  /// No description provided for @environmentalImpact.
  ///
  /// In en, this message translates to:
  /// **'🌱 Environmental Impact'**
  String get environmentalImpact;

  /// No description provided for @co2Avoided.
  ///
  /// In en, this message translates to:
  /// **'CO₂ avoided: {co2} ton / year'**
  String co2Avoided(String co2);

  /// No description provided for @equivalentTrees.
  ///
  /// In en, this message translates to:
  /// **'Equivalent: {trees} trees / year'**
  String equivalentTrees(int trees);

  /// No description provided for @environmentalEstimationNote.
  ///
  /// In en, this message translates to:
  /// **'These values are estimates based on consumption and sunlight.'**
  String get environmentalEstimationNote;

  /// No description provided for @searchCompaniesOrTechnicians.
  ///
  /// In en, this message translates to:
  /// **'Search for companies or technicians'**
  String get searchCompaniesOrTechnicians;

  /// No description provided for @searchCompaniesOrTechniciansDescription.
  ///
  /// In en, this message translates to:
  /// **'Find certified professionals near you.'**
  String get searchCompaniesOrTechniciansDescription;

  /// No description provided for @whatAreYouLookingFor.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get whatAreYouLookingFor;

  /// No description provided for @searchCertifiedCompanies.
  ///
  /// In en, this message translates to:
  /// **'Search for certified companies'**
  String get searchCertifiedCompanies;

  /// No description provided for @searchCertifiedTechnicians.
  ///
  /// In en, this message translates to:
  /// **'Search for certified technicians'**
  String get searchCertifiedTechnicians;

  /// No description provided for @companiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Partner and certified companies'**
  String get companiesSubtitle;

  /// No description provided for @techniciansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Qualified and certified technicians'**
  String get techniciansSubtitle;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @noCompaniesFound.
  ///
  /// In en, this message translates to:
  /// **'No companies found'**
  String get noCompaniesFound;

  /// No description provided for @noTechniciansFound.
  ///
  /// In en, this message translates to:
  /// **'No technicians found'**
  String get noTechniciansFound;

  /// No description provided for @serviceType.
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get serviceType;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @speciality.
  ///
  /// In en, this message translates to:
  /// **'Speciality'**
  String get speciality;

  /// No description provided for @ice.
  ///
  /// In en, this message translates to:
  /// **'ICE'**
  String get ice;

  /// No description provided for @ifCode.
  ///
  /// In en, this message translates to:
  /// **'IF'**
  String get ifCode;

  /// No description provided for @rc.
  ///
  /// In en, this message translates to:
  /// **'RC'**
  String get rc;

  /// No description provided for @patente.
  ///
  /// In en, this message translates to:
  /// **'Patente'**
  String get patente;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @companyDocuments.
  ///
  /// In en, this message translates to:
  /// **'Company documents'**
  String get companyDocuments;

  /// No description provided for @certificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificates;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
