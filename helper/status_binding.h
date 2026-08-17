#pragma once

#include <windows.h>
#include <cfg.h>

#include <algorithm>
#include <cwctype>
#include <optional>
#include <string>
#include <string_view>

namespace status_binding {

struct PrecisionBindingEvidence {
    std::wstring friendlyName;
    std::wstring provider;
    bool hasInfPath = false;
    bool hasDriverVersion = false;
    std::optional<ULONG> devNodeStatus;
};

inline std::wstring ToUpper(std::wstring value) {
    std::transform(
        value.begin(),
        value.end(),
        value.begin(),
        [](wchar_t ch) {
            return static_cast<wchar_t>(std::towupper(ch));
        });

    return value;
}

inline bool ContainsI(
    std::wstring_view haystack,
    std::wstring_view needle) {

    const std::wstring upperHaystack =
        ToUpper(std::wstring(haystack));
    const std::wstring upperNeedle =
        ToUpper(std::wstring(needle));

    return upperHaystack.find(upperNeedle) !=
           std::wstring::npos;
}

inline bool HasUpstreamDriverIdentity(
    const PrecisionBindingEvidence& evidence) {

    const bool expectedProvider =
        ContainsI(evidence.provider, L"BINGXING WANG") ||
        ContainsI(evidence.provider, L"VITO PLANTAMURA");

    return expectedProvider &&
           evidence.hasInfPath &&
           evidence.hasDriverVersion;
}

inline bool IsDevNodeStarted(
    const std::optional<ULONG>& devNodeStatus) {

    return devNodeStatus.has_value() &&
           (devNodeStatus.value() & DN_STARTED) != 0;
}

inline bool HasDevNodeProblem(
    const std::optional<ULONG>& devNodeStatus) {

    return devNodeStatus.has_value() &&
           (devNodeStatus.value() & DN_HAS_PROBLEM) != 0;
}

inline bool IsUpstreamDriverBound(
    const PrecisionBindingEvidence& evidence) {

    // FriendlyName intentionally does not prove binding.
    // It may identify an interface, but real binding requires
    // upstream driver identity plus a started/problem-free devnode.
    return HasUpstreamDriverIdentity(evidence) &&
           IsDevNodeStarted(evidence.devNodeStatus) &&
           !HasDevNodeProblem(evidence.devNodeStatus);
}

} // namespace status_binding
