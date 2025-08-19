/// Service to handle callbacks after subscription changes
class SubscriptionCallbackService {
  static final SubscriptionCallbackService _instance = SubscriptionCallbackService._internal();
  factory SubscriptionCallbackService() => _instance;
  SubscriptionCallbackService._internal();

  Function? _onSubscriptionSuccess;

  /// Set callback to be called after successful subscription
  void setOnSubscriptionSuccess(Function callback) {
    _onSubscriptionSuccess = callback;
  }

  /// Execute callback if set
  void executeSubscriptionSuccessCallback() {
    if (_onSubscriptionSuccess != null) {
      _onSubscriptionSuccess!();
      _onSubscriptionSuccess = null; // Clear after execution
    }
  }

  /// Clear callback
  void clearCallback() {
    _onSubscriptionSuccess = null;
  }
}