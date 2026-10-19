import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/models/command_descriptor.dart';
import 'package:hermes_android/core/services/capability_payload_sanitizer.dart';

void main() {
  test('a long skill body survives sanitization and result parsing intact', () {
    final message = '${'Follow these skill instructions.\n' * 700}END OF SKILL';
    final result = DesktopCommandRpcResult.fromJson(
      const CapabilityPayloadSanitizer().sanitizeCommandResponse({
        'type': 'skill',
        'name': 'long-skill',
        'message': message,
      }),
    );

    expect(result.kind, DesktopCommandDispatchKind.skill);
    expect(result.accepted, DesktopCommandAcceptance.accepted);
    expect(result.message, message);
  });

  test('skill messages preserve whitespace and Unicode', () {
    const message = '  Instructions\n\t保留 this text.\n  ';
    final result = DesktopCommandRpcResult.fromJson(
      const CapabilityPayloadSanitizer().sanitizeCommandResponse({
        'type': 'skill',
        'message': message,
      }),
    );
    expect(result.message, message);
  });

  test('oversized messages are rejected rather than partially submitted', () {
    final payload = {'type': 'skill', 'message': 'x' * (1024 * 1024 + 1)};
    expect(
      () => const CapabilityPayloadSanitizer().sanitizeCommandResponse(payload),
      throwsFormatException,
    );
    expect(
      () => DesktopCommandRpcResult.fromJson(payload),
      throwsFormatException,
    );
  });

  test('invalid control characters are rejected rather than rewritten', () {
    final payload = {'type': 'skill', 'message': 'before\u0000after'};
    expect(
      () => const CapabilityPayloadSanitizer().sanitizeCommandResponse(payload),
      throwsFormatException,
    );
    expect(
      () => DesktopCommandRpcResult.fromJson(payload),
      throwsFormatException,
    );
  });
}
