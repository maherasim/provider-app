import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_data.dart';

extension RemoteWorkLevelLocalization on RemoteWorkLevel {
  String get localizedLabel {
    switch (this) {
      case RemoteWorkLevel.onsite0:
        return languages.lblRemoteWorkOnsite100;
      case RemoteWorkLevel.remote25:
        return languages.lblRemoteWork25;
      case RemoteWorkLevel.remote50:
        return languages.lblRemoteWork50;
      case RemoteWorkLevel.remote75:
        return languages.lblRemoteWork75;
      case RemoteWorkLevel.remote100:
        return languages.lblRemoteWork100;
    }
  }
}

extension CareerLevelLocalization on CareerLevel {
  String get localizedLabel {
    switch (this) {
      case CareerLevel.notSpecified:
        return languages.lblCareerNotSpecified;
      case CareerLevel.entryLevel:
        return languages.lblCareerEntryLevel;
      case CareerLevel.intermediateLevel:
        return languages.lblCareerIntermediateLevel;
      case CareerLevel.experienced:
        return languages.lblCareerExperienced;
      case CareerLevel.professional:
        return languages.lblCareerProfessional;
      case CareerLevel.middleManagement:
        return languages.lblCareerMiddleManagement;
      case CareerLevel.executiveManagement:
        return languages.lblCareerExecutiveManagement;
      case CareerLevel.seniorManagement:
        return languages.lblCareerSeniorManagement;
      case CareerLevel.director:
        return languages.lblCareerDirector;
      case CareerLevel.technician:
        return languages.lblCareerTechnician;
      case CareerLevel.leader:
        return languages.lblCareerLeader;
      case CareerLevel.manager:
        return languages.lblCareerManager;
    }
  }
}

extension TravelRequirementLocalization on TravelRequirement {
  String get localizedLabel {
    switch (this) {
      case TravelRequirement.no:
        return languages.lblNo;
      case TravelRequirement.yes:
        return languages.lblYes;
    }
  }
}

extension EducationLevelLocalization on EducationLevel {
  String get localizedLabel {
    switch (this) {
      case EducationLevel.notSpecified:
        return languages.lblEduNotSpecified;
      case EducationLevel.anyGraduate:
        return languages.lblEduAnyGraduate;
      case EducationLevel.apprenticeshipDegree:
        return languages.lblEduApprenticeship;
      case EducationLevel.traineeshipDegree:
        return languages.lblEduTraineeship;
      case EducationLevel.secondaryDegree:
        return languages.lblEduSecondaryDegree;
      case EducationLevel.undergraduateDiploma:
        return languages.lblEduUndergraduate;
      case EducationLevel.highSchoolGraduate:
        return languages.lblEduHighSchool;
      case EducationLevel.associateDegree:
        return languages.lblEduAssociate;
      case EducationLevel.collegeDegree:
        return languages.lblEduCollege;
      case EducationLevel.universityDegree:
        return languages.lblEduUniversity;
      case EducationLevel.bachelorsDegree:
        return languages.lblEduBachelors;
      case EducationLevel.mastersDegree:
        return languages.lblEduMasters;
      case EducationLevel.doctorateDegree:
        return languages.lblEduDoctorate;
      case EducationLevel.professionalDegree:
        return languages.lblEduProfessional;
      case EducationLevel.notSpecified2:
        return languages.lblEduNotSpecified2;
      case EducationLevel.anyGraduate2:
        return languages.lblEduAnyGraduate2;
      case EducationLevel.apprenticeshipDegree2:
        return languages.lblEduApprenticeship2;
      case EducationLevel.traineeshipDegree2:
        return languages.lblEduTraineeship2;
      case EducationLevel.secondaryDegree2:
        return languages.lblEduSecondaryDegree2;
      case EducationLevel.undergraduateDiploma2:
        return languages.lblEduUndergraduate2;
    }
  }
}
