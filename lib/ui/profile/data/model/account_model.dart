import 'package:flutter/material.dart';

class AccountModel {
  // ============================================================
  // BASIC ACCOUNT
  // ============================================================

  final String id;
  final String name;
  final String email;
  final String mobile;
  final String altMobile;
  final String orgName;
  final String photo;

  // ============================================================
  // ADDRESS
  // ============================================================

  final String address;
  final String stateName;
  final String stateId;
  final String city;
  final String pincode;

  // ============================================================
  // GST
  // ============================================================

  final String gstType;
  final String gstNo;

  // ============================================================
  // AGENT
  // ============================================================

  final String agentName;
  final String agentNo;

  // ============================================================
  // COUNTS
  // ============================================================

  final String totalFavourate;
  final String totalCartCheck;
  final String totalOrder;

  // ============================================================
  // APP / COMPANY INFO
  // ============================================================

  final String developedBy;
  final String androidVersion;
  final String iosVersion;
  final String onlineService;
  final String whatsappNumber;
  final String outstanding;
  final String dueDays;
  final String status;

  // ============================================================
  // PAGES
  // ============================================================

  final String aboutUs;
  final String privacyPolicy;
  final String contactUs;
  final String termCondition;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  AccountModel({
    this.id = '',
    this.name = '',
    this.email = '',
    this.mobile = '',
    this.altMobile = '',
    this.orgName = '',
    this.photo = '',

    this.address = '',
    this.stateName = '',
    this.stateId = '',
    this.city = '',
    this.pincode = '',

    this.gstType = '',
    this.gstNo = '',

    this.agentName = '',
    this.agentNo = '',

    this.totalFavourate = '',
    this.totalCartCheck = '',
    this.totalOrder = '',

    this.developedBy = '',
    this.androidVersion = '',
    this.iosVersion = '',
    this.onlineService = '',
    this.whatsappNumber = '',
    this.outstanding = '',
    this.dueDays = '',
    this.status = '',

    this.aboutUs = '',
    this.privacyPolicy = '',
    this.contactUs = '',
    this.termCondition = '',
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory AccountModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AccountModel(
      // ----------------------------------------------------------
      // BASIC
      // ----------------------------------------------------------

      id: json['id']?.toString() ?? '',

      name: json['name']?.toString() ?? '',

      email: json['email']?.toString() ?? '',

      mobile: json['mobile']?.toString() ?? '',

      altMobile:
      json['alt_mobile']?.toString() ?? '',

      orgName:
      json['company']?.toString() ?? '',

      photo:
      json['photo']?.toString() ?? '',

      // ----------------------------------------------------------
      // ADDRESS
      // ----------------------------------------------------------

      address:
      json['address']?.toString() ?? '',

      stateName:
      json['state_name']?.toString() ?? '',

      stateId:
      json['state_id']?.toString() ?? '',

      city:
      json['city']?.toString() ?? '',

      pincode:
      json['pincode']?.toString() ?? '',

      // ----------------------------------------------------------
      // GST
      // ----------------------------------------------------------

      gstType:
      json['gst_type']?.toString() ?? '',

      gstNo:
      json['gst_no']?.toString() ?? '',

      // ----------------------------------------------------------
      // AGENT
      // ----------------------------------------------------------

      agentName:
      json['agentname']?.toString() ?? '',

      agentNo:
      json['agentno']?.toString() ?? '',

      // ----------------------------------------------------------
      // COUNTS
      // ----------------------------------------------------------

      totalFavourate:
      json['TotalFavourate']?.toString() ?? '',

      totalCartCheck:
      json['TotalCartCheck']?.toString() ?? '',

      totalOrder:
      json['TotalOrder']?.toString() ?? '',

      // ----------------------------------------------------------
      // APP / COMPANY INFO
      // ----------------------------------------------------------

      developedBy:
      json['DevelopedBy']?.toString() ?? '',

      androidVersion:
      json['Android_Version']?.toString() ?? '',

      iosVersion:
      json['IOS_Version']?.toString() ?? '',

      onlineService:
      json['Online_Service']?.toString() ?? '',

      whatsappNumber:
      json['whatsapp_number']?.toString() ?? '',

      outstanding:
      json['Outstanding']?.toString() ?? '',

      dueDays:
      json['Duedays']?.toString() ?? '',

      status:
      json['Staus']?.toString() ?? '',

      // ----------------------------------------------------------
      // PAGES
      // ----------------------------------------------------------

      aboutUs:
      json['Aboutus']?.toString() ?? '',

      privacyPolicy:
      json['Privacy_Policy']?.toString() ?? '',

      contactUs:
      json['Contactus']?.toString() ?? '',

      termCondition:
      json['Termcondition']?.toString() ?? '',
    );
  }
}


class AccountMenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  AccountMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });
}