#include "helper/status_binding.h"

#include <iostream>
#include <string>

namespace {

int failures = 0;

void Expect(
    bool actual,
    bool expected,
    const char* name) {

    if (actual == expected) {
        std::cout << "[PASS] " << name << "\n";
        return;
    }

    ++failures;
    std::cerr
        << "[FAIL] "
        << name
        << " expected="
        << (expected ? "true" : "false")
        << " actual="
        << (actual ? "true" : "false")
        << "\n";
}

status_binding::PrecisionBindingEvidence Healthy(
    std::wstring friendlyName) {

    return {
        std::move(friendlyName),
        L"Bingxing Wang, Vito Plantamura",
        true,
        true,
        static_cast<ULONG>(DN_STARTED)
    };
}

} // namespace

int main() {
    {
        const auto evidence =
            Healthy(L"Apple USB Precision Touchpad Device (User-mode)");

        Expect(
            status_binding::IsUpstreamDriverBound(evidence),
            true,
            "healthy USB Precision target is bound");
    }

    {
        const auto evidence =
            Healthy(L"Apple Multi-touch Trackpad HID Filter");

        Expect(
            status_binding::IsUpstreamDriverBound(evidence),
            true,
            "healthy Bluetooth Precision filter is bound");
    }

    {
        status_binding::PrecisionBindingEvidence evidence{
            L"Apple USB Precision Touchpad Device (User-mode)",
            L"",
            false,
            false,
            static_cast<ULONG>(DN_STARTED)
        };

        Expect(
            status_binding::IsUpstreamDriverBound(evidence),
            false,
            "friendly name alone never proves USB binding");
    }

    {
        status_binding::PrecisionBindingEvidence evidence{
            L"Apple Multi-touch Trackpad HID Filter",
            L"",
            false,
            false,
            static_cast<ULONG>(DN_STARTED)
        };

        Expect(
            status_binding::IsUpstreamDriverBound(evidence),
            false,
            "friendly name alone never proves Bluetooth binding");
    }

    {
        status_binding::PrecisionBindingEvidence evidence{
            L"Apple USB Precision Touchpad Device (User-mode)",
            L"Microsoft",
            true,
            true,
            static_cast<ULONG>(DN_STARTED)
        };

        Expect(
            status_binding::IsUpstreamDriverBound(evidence),
            false,
            "unexpected provider fails closed");
    }

    {
        auto evidence =
            Healthy(L"Apple USB Precision Touchpad Device (User-mode)");

        evidence.devNodeStatus = static_cast<ULONG>(0);

        Expect(
            status_binding::IsUpstreamDriverBound(evidence),
            false,
            "upstream identity without DN_STARTED fails closed");
    }

    {
        auto evidence =
            Healthy(L"Apple USB Precision Touchpad Device (User-mode)");

        evidence.devNodeStatus =
            static_cast<ULONG>(DN_STARTED | DN_HAS_PROBLEM);

        Expect(
            status_binding::IsUpstreamDriverBound(evidence),
            false,
            "started devnode with DN_HAS_PROBLEM is not bound");
    }

    {
        auto evidence =
            Healthy(L"Apple USB Precision Touchpad Device (User-mode)");

        evidence.devNodeStatus = std::nullopt;

        Expect(
            status_binding::IsUpstreamDriverBound(evidence),
            false,
            "unknown devnode status fails closed");
    }

    {
        auto evidence =
            Healthy(L"Apple USB Precision Touchpad Device (User-mode)");

        evidence.hasInfPath = false;

        Expect(
            status_binding::IsUpstreamDriverBound(evidence),
            false,
            "missing installed INF fails closed");
    }

    {
        auto evidence =
            Healthy(L"Apple USB Precision Touchpad Device (User-mode)");

        evidence.hasDriverVersion = false;

        Expect(
            status_binding::IsUpstreamDriverBound(evidence),
            false,
            "missing driver version fails closed");
    }

    if (failures != 0) {
        std::cerr
            << failures
            << " status-binding regression test(s) failed.\n";
        return 1;
    }

    std::cout
        << "[PASS] All status-binding regression tests passed.\n";

    return 0;
}
