class InstanceInfo {
  final String instanceName;
  final String? description;
  final String version;
  final int messageLimit;
  final String oprishUrl;
  final String pandemoniumUrl;
  final String effisUrl;
  final int fileSize;
  final int attachmentFileSize;

  InstanceInfo({
    required this.instanceName,
    required this.description,
    required this.version,
    required this.messageLimit,
    required this.oprishUrl,
    required this.pandemoniumUrl,
    required this.effisUrl,
    required this.fileSize,
    required this.attachmentFileSize,
  });

  factory InstanceInfo.fromJson(Map<String, dynamic> json) {
    return InstanceInfo(
      instanceName: json['instance_name'],
      description: json['description'],
      version: json['version'],
      messageLimit: json['message_limit'],
      oprishUrl: json['oprish_url'],
      pandemoniumUrl: json['pandemonium_url'],
      effisUrl: json['effis_url'],
      fileSize: json['file_size'],
      attachmentFileSize: json['attachment_file_size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instance_name': instanceName,
      'description': description,
      'version': version,
      'message_limit': messageLimit,
      'oprish_url': oprishUrl,
      'pandemonium_url': pandemoniumUrl,
      'effis_url': effisUrl,
      'file_size': fileSize,
      'attachment_file_size': attachmentFileSize,
    };
  }
}
