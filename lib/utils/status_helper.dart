String getConfidenceLabel(DateTime updatedAt) {
  final minutes = DateTime.now().difference(updatedAt).inMinutes;

  if (minutes < 10) return "High confidence";
  if (minutes < 30) return "Medium confidence";
  return "Low confidence";
}
