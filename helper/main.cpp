#include <windows.h>
#include <setupapi.h>
#include <cfgmgr32.h>
#include <cfg.h>
#include <initguid.h>
#include <devpkey.h>
#include <bluetoothapis.h>
#include "status_binding.h"

#include <algorithm>
#include <cctype>
#include <cwctype>
#include <filesystem>
#include <iomanip>
#include <iostream>
#include <optional>
#include <sstream>
#include <system_error>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

#pragma comment(lib, "setupapi.lib")
#pragma comment(lib, "cfgmgr32.lib")
#pragma comment(lib, "bthprops.lib")

namespace {

struct DeviceInfo {
    std::wstring instanceId;
    std::wstring name;
    std::wstring infPath;
    std::wstring provider;
    std::wstring driverVersion;
    std::optional<ULONG> devNodeStatus;
    std::optional<ULONG> problemCode;
};

struct BluetoothState {
    bool found = false;
    bool remembered = false;
    bool paired = false;
    bool connected = false;
    std::wstring name;
    ULONGLONG address = 0;
};

struct DriverPackage {
    std::wstring publishedInf;
    std::wstring originalInf;
    std::wstring originalCatalog;
    std::wstring provider;
    std::wstring driverDate;
    std::wstring driverVersion;
    std::wstring infPath;
};

constexpr std::wstring_view kExpectedOriginalInf = L"AmtPtpDevice.inf";
constexpr std::wstring_view kExpectedCatalog = L"AmtPtpDevice.cat";
constexpr std::wstring_view kExpectedProvider = L"Bingxing Wang, Vito Plantamura";
constexpr std::wstring_view kExpectedDriverVersion = L"2025.3980.1.1000";

std::wstring ToUpper(std::wstring value) {
    std::transform(value.begin(), value.end(), value.begin(),
        [](wchar_t ch) { return static_cast<wchar_t>(std::towupper(ch)); });
    return value;
}

bool ContainsI(std::wstring_view haystack, std::wstring_view needle) {
    const std::wstring h = ToUpper(std::wstring(haystack));
    const std::wstring n = ToUpper(std::wstring(needle));
    return h.find(n) != std::wstring::npos;
}

std::string Utf8(std::wstring_view text) {
    if (text.empty()) {
        return {};
    }

    const int required = WideCharToMultiByte(
        CP_UTF8, 0, text.data(), static_cast<int>(text.size()),
        nullptr, 0, nullptr, nullptr);

    if (required <= 0) {
        return {};
    }

    std::string result(static_cast<size_t>(required), '\0');
    WideCharToMultiByte(
        CP_UTF8, 0, text.data(), static_cast<int>(text.size()),
        result.data(), required, nullptr, nullptr);
    return result;
}

std::wstring GetRegistryPropertyString(
    HDEVINFO deviceInfoSet,
    SP_DEVINFO_DATA& deviceInfoData,
    DWORD property) {

    DWORD required = 0;
    DWORD type = 0;

    SetupDiGetDeviceRegistryPropertyW(
        deviceInfoSet,
        &deviceInfoData,
        property,
        &type,
        nullptr,
        0,
        &required);

    if (required == 0) {
        return {};
    }

    std::vector<BYTE> buffer(required);
    if (!SetupDiGetDeviceRegistryPropertyW(
            deviceInfoSet,
            &deviceInfoData,
            property,
            &type,
            buffer.data(),
            required,
            nullptr)) {
        return {};
    }

    return std::wstring(reinterpret_cast<const wchar_t*>(buffer.data()));
}

std::wstring GetDevicePropertyString(
    HDEVINFO deviceInfoSet,
    SP_DEVINFO_DATA& deviceInfoData,
    const DEVPROPKEY& key) {

    DEVPROPTYPE type = 0;
    DWORD required = 0;

    SetupDiGetDevicePropertyW(
        deviceInfoSet,
        &deviceInfoData,
        &key,
        &type,
        nullptr,
        0,
        &required,
        0);

    if (required == 0) {
        return {};
    }

    std::vector<BYTE> buffer(required);
    if (!SetupDiGetDevicePropertyW(
            deviceInfoSet,
            &deviceInfoData,
            &key,
            &type,
            buffer.data(),
            required,
            nullptr,
            0)) {
        return {};
    }

    if (type != DEVPROP_TYPE_STRING) {
        return {};
    }

    return std::wstring(reinterpret_cast<const wchar_t*>(buffer.data()));
}

void PopulateDeviceNodeState(
    const SP_DEVINFO_DATA& deviceInfoData,
    DeviceInfo& device) {

    ULONG status = 0;
    ULONG problem = 0;

    const CONFIGRET result = CM_Get_DevNode_Status(
        &status,
        &problem,
        deviceInfoData.DevInst,
        0);

    if (result != CR_SUCCESS) {
        return;
    }

    device.devNodeStatus = status;

    if ((status & DN_HAS_PROBLEM) != 0) {
        device.problemCode = problem;
    }
}

std::wstring GetInstanceId(
    HDEVINFO deviceInfoSet,
    SP_DEVINFO_DATA& deviceInfoData) {

    DWORD required = 0;
    SetupDiGetDeviceInstanceIdW(
        deviceInfoSet,
        &deviceInfoData,
        nullptr,
        0,
        &required);

    if (required == 0) {
        return {};
    }

    std::vector<wchar_t> buffer(required);
    if (!SetupDiGetDeviceInstanceIdW(
            deviceInfoSet,
            &deviceInfoData,
            buffer.data(),
            required,
            nullptr)) {
        return {};
    }

    return std::wstring(buffer.data());
}

std::vector<DeviceInfo> EnumeratePresentDevices() {
    std::vector<DeviceInfo> devices;

    HDEVINFO deviceInfoSet = SetupDiGetClassDevsW(
        nullptr,
        nullptr,
        nullptr,
        DIGCF_PRESENT | DIGCF_ALLCLASSES);

    if (deviceInfoSet == INVALID_HANDLE_VALUE) {
        return devices;
    }

    for (DWORD index = 0;; ++index) {
        SP_DEVINFO_DATA data{};
        data.cbSize = sizeof(data);

        if (!SetupDiEnumDeviceInfo(deviceInfoSet, index, &data)) {
            if (GetLastError() == ERROR_NO_MORE_ITEMS) {
                break;
            }
            continue;
        }

        DeviceInfo device;
        device.instanceId = GetInstanceId(deviceInfoSet, data);
        device.name = GetRegistryPropertyString(
            deviceInfoSet, data, SPDRP_FRIENDLYNAME);

        if (device.name.empty()) {
            device.name = GetRegistryPropertyString(
                deviceInfoSet, data, SPDRP_DEVICEDESC);
        }

        device.infPath = GetDevicePropertyString(
            deviceInfoSet, data, DEVPKEY_Device_DriverInfPath);
        device.provider = GetDevicePropertyString(
            deviceInfoSet, data, DEVPKEY_Device_DriverProvider);
        device.driverVersion = GetDevicePropertyString(
            deviceInfoSet, data, DEVPKEY_Device_DriverVersion);
        PopulateDeviceNodeState(data, device);

        devices.push_back(std::move(device));
    }

    SetupDiDestroyDeviceInfoList(deviceInfoSet);
    return devices;
}

bool IsA3120Related(const DeviceInfo& device) {
    return ContainsI(device.instanceId, L"VID_05AC&PID_0324") ||
           ContainsI(device.instanceId, L"PID&0324") ||
           ContainsI(device.name, L"MAGIC TRACKPAD") ||
           ContainsI(device.name, L"APPLE MULTI-TOUCH TRACKPAD");
}

bool IsUsbA3120(const DeviceInfo& device) {
    return ContainsI(device.instanceId, L"USB\\VID_05AC&PID_0324");
}

bool IsUsbPrecisionInterface(const DeviceInfo& device) {
    return ContainsI(device.instanceId, L"USB\\VID_05AC&PID_0324&MI_01");
}

bool IsBluetoothPnpA3120(const DeviceInfo& device) {
    return (ContainsI(device.instanceId, L"BTHENUM") &&
            ContainsI(device.instanceId, L"PID&0324")) ||
           ContainsI(device.name, L"MAGIC TRACKPAD");
}

bool IsBluetoothPrecisionInterface(const DeviceInfo& device) {
    return ContainsI(device.instanceId, L"PID&0324&COL01") &&
           (ContainsI(device.name, L"APPLE MULTI-TOUCH TRACKPAD HID FILTER") ||
            ContainsI(device.provider, L"BINGXING WANG") ||
            ContainsI(device.provider, L"VITO PLANTAMURA"));
}

status_binding::PrecisionBindingEvidence MakeBindingEvidence(
    const DeviceInfo& device) {

    return {
        device.name,
        device.provider,
        !device.infPath.empty(),
        !device.driverVersion.empty(),
        device.devNodeStatus
    };
}

bool IsUpstreamDriverBound(const DeviceInfo& device) {
    return status_binding::IsUpstreamDriverBound(
        MakeBindingEvidence(device));
}

std::optional<ULONGLONG> ExtractBluetoothAddress(
    const std::vector<DeviceInfo>& devices) {

    constexpr std::wstring_view marker = L"BTHENUM\\DEV_";

    for (const auto& device : devices) {
        if (!IsBluetoothPnpA3120(device)) {
            continue;
        }

        const std::wstring upper = ToUpper(device.instanceId);
        const size_t pos = upper.find(marker);

        if (pos == std::wstring::npos) {
            continue;
        }

        const size_t start = pos + marker.size();
        if (upper.size() < start + 12) {
            continue;
        }

        const std::wstring hex = upper.substr(start, 12);
        if (!std::all_of(hex.begin(), hex.end(),
                [](wchar_t ch) { return std::iswxdigit(ch) != 0; })) {
            continue;
        }

        try {
            return std::stoull(hex, nullptr, 16);
        }
        catch (...) {
            continue;
        }
    }

    return std::nullopt;
}

std::wstring FormatBluetoothAddress(ULONGLONG address) {
    std::wostringstream out;
    out << std::uppercase
        << std::hex
        << std::setfill(L'0')
        << std::setw(12)
        << (address & 0x0000FFFFFFFFFFFFULL);

    const std::wstring raw = out.str();
    std::wstring formatted;

    for (size_t i = 0; i < raw.size(); i += 2) {
        if (!formatted.empty()) {
            formatted.push_back(L':');
        }
        formatted.append(raw.substr(i, 2));
    }

    return formatted;
}

BluetoothState QueryBluetoothState(
    const std::optional<ULONGLONG>& expectedAddress) {

    BluetoothState state;

    BLUETOOTH_DEVICE_SEARCH_PARAMS params{};
    params.dwSize = sizeof(params);
    params.fReturnAuthenticated = TRUE;
    params.fReturnRemembered = TRUE;
    params.fReturnUnknown = TRUE;
    params.fReturnConnected = TRUE;
    params.fIssueInquiry = FALSE;
    params.cTimeoutMultiplier = 0;
    params.hRadio = nullptr;

    BLUETOOTH_DEVICE_INFO info{};
    info.dwSize = sizeof(info);

    HBLUETOOTH_DEVICE_FIND find =
        BluetoothFindFirstDevice(&params, &info);

    if (find == nullptr) {
        return state;
    }

    do {
        const bool addressMatch =
            expectedAddress.has_value() &&
            info.Address.ullLong == expectedAddress.value();

        const bool nameFallback =
            !expectedAddress.has_value() &&
            ContainsI(info.szName, L"MAGIC TRACKPAD");

        if (addressMatch || nameFallback) {
            state.found = true;
            state.remembered = info.fRemembered != FALSE;
            state.paired = info.fAuthenticated != FALSE;
            state.connected = info.fConnected != FALSE;
            state.name = info.szName;
            state.address = info.Address.ullLong;
            break;
        }

        info = {};
        info.dwSize = sizeof(info);
    } while (BluetoothFindNextDevice(find, &info));

    BluetoothFindDeviceClose(find);
    return state;
}


std::wstring Trim(std::wstring value) {
    const auto notSpace = [](wchar_t ch) {
        return std::iswspace(ch) == 0;
    };

    value.erase(
        value.begin(),
        std::find_if(value.begin(), value.end(), notSpace));

    value.erase(
        std::find_if(value.rbegin(), value.rend(), notSpace).base(),
        value.end());

    if (value.size() >= 2 &&
        ((value.front() == L'"' && value.back() == L'"') ||
         (value.front() == L'\'' && value.back() == L'\''))) {
        value = value.substr(1, value.size() - 2);
    }

    return value;
}

std::wstring ReadIniValue(
    const std::wstring& path,
    const wchar_t* section,
    const wchar_t* key) {

    std::vector<wchar_t> buffer(4096, L'\0');

    const DWORD written = GetPrivateProfileStringW(
        section,
        key,
        L"",
        buffer.data(),
        static_cast<DWORD>(buffer.size()),
        path.c_str());

    if (written == 0) {
        return {};
    }

    return Trim(std::wstring(buffer.data(), written));
}

std::optional<DriverPackage> ReadDriverPackage(
    const std::filesystem::path& infPath) {

    DWORD required = 0;
    SetupGetInfInformationW(
        infPath.c_str(),
        INFINFO_INF_NAME_IS_ABSOLUTE,
        nullptr,
        0,
        &required);

    if (required == 0) {
        return std::nullopt;
    }

    std::vector<BYTE> buffer(required);
    auto* infInfo =
        reinterpret_cast<PSP_INF_INFORMATION>(buffer.data());

    if (!SetupGetInfInformationW(
            infPath.c_str(),
            INFINFO_INF_NAME_IS_ABSOLUTE,
            infInfo,
            required,
            nullptr)) {
        return std::nullopt;
    }

    SP_ORIGINAL_FILE_INFO_W original{};
    original.cbSize = sizeof(original);

    if (!SetupQueryInfOriginalFileInformationW(
            infInfo,
            0,
            nullptr,
            &original)) {
        return std::nullopt;
    }

    DriverPackage package;
    package.infPath = infPath.wstring();
    package.publishedInf = infPath.filename().wstring();
    package.originalInf = original.OriginalInfName;
    package.originalCatalog = original.OriginalCatalogName;
    package.provider = ReadIniValue(
        package.infPath, L"Strings", L"ManufacturerName");

    const std::wstring driverVer = ReadIniValue(
        package.infPath, L"Version", L"DriverVer");

    const size_t comma = driverVer.find(L',');
    if (comma != std::wstring::npos) {
        package.driverDate = Trim(driverVer.substr(0, comma));
        package.driverVersion = Trim(driverVer.substr(comma + 1));
    }
    else {
        package.driverVersion = Trim(driverVer);
    }

    return package;
}

bool IsExpectedDriverPackage(const DriverPackage& package) {
    return ToUpper(package.originalInf) ==
               ToUpper(std::wstring(kExpectedOriginalInf)) &&
           ToUpper(package.originalCatalog) ==
               ToUpper(std::wstring(kExpectedCatalog)) &&
           ToUpper(package.provider) ==
               ToUpper(std::wstring(kExpectedProvider));
}

std::vector<DriverPackage> EnumerateInstalledDriverPackages() {
    std::vector<DriverPackage> packages;

    wchar_t windowsDir[MAX_PATH]{};
    const UINT length =
        GetWindowsDirectoryW(windowsDir, ARRAYSIZE(windowsDir));

    if (length == 0 || length >= ARRAYSIZE(windowsDir)) {
        return packages;
    }

    const std::filesystem::path infDir =
        std::filesystem::path(windowsDir) / L"INF";

    std::error_code ec;
    std::filesystem::directory_iterator iterator(infDir, ec);
    std::filesystem::directory_iterator end;

    for (; !ec && iterator != end; iterator.increment(ec)) {
        const auto& entry = *iterator;

        if (!entry.is_regular_file(ec) || ec) {
            continue;
        }

        const std::wstring filename =
            ToUpper(entry.path().filename().wstring());
        const std::wstring extension =
            ToUpper(entry.path().extension().wstring());

        if (filename.rfind(L"OEM", 0) != 0 ||
            extension != L".INF") {
            continue;
        }

        const auto package = ReadDriverPackage(entry.path());
        if (package.has_value() &&
            IsExpectedDriverPackage(*package)) {
            packages.push_back(*package);
        }
    }

    std::sort(
        packages.begin(),
        packages.end(),
        [](const DriverPackage& a, const DriverPackage& b) {
            return ToUpper(a.publishedInf) <
                   ToUpper(b.publishedInf);
        });

    return packages;
}

std::vector<unsigned long long> ParseVersion(
    std::wstring_view version) {

    std::vector<unsigned long long> parts;
    std::wstring current;

    for (const wchar_t ch : version) {
        if (ch == L'.') {
            if (current.empty()) {
                return {};
            }

            try {
                parts.push_back(std::stoull(current));
            }
            catch (...) {
                return {};
            }

            current.clear();
        }
        else if (std::iswdigit(ch) != 0) {
            current.push_back(ch);
        }
        else {
            return {};
        }
    }

    if (current.empty()) {
        return {};
    }

    try {
        parts.push_back(std::stoull(current));
    }
    catch (...) {
        return {};
    }

    return parts;
}

int CompareVersions(
    std::wstring_view left,
    std::wstring_view right) {

    const auto a = ParseVersion(left);
    const auto b = ParseVersion(right);

    if (a.empty() || b.empty()) {
        const int lexical = ToUpper(std::wstring(left)).compare(
            ToUpper(std::wstring(right)));
        return lexical < 0 ? -1 : lexical > 0 ? 1 : 0;
    }

    const size_t count = std::max(a.size(), b.size());

    for (size_t i = 0; i < count; ++i) {
        const auto av = i < a.size() ? a[i] : 0;
        const auto bv = i < b.size() ? b[i] : 0;

        if (av < bv) {
            return -1;
        }
        if (av > bv) {
            return 1;
        }
    }

    return 0;
}

void PrintDriverPackage(
    const DriverPackage& package,
    size_t index) {

    std::cout << "package." << index
              << ".published_inf="
              << Utf8(package.publishedInf) << "\n";
    std::cout << "package." << index
              << ".original_inf="
              << Utf8(package.originalInf) << "\n";
    std::cout << "package." << index
              << ".catalog="
              << Utf8(package.originalCatalog) << "\n";
    std::cout << "package." << index
              << ".provider="
              << Utf8(package.provider) << "\n";
    std::cout << "package." << index
              << ".driver_date="
              << Utf8(package.driverDate) << "\n";
    std::cout << "package." << index
              << ".driver_version="
              << Utf8(package.driverVersion) << "\n";
}

int DriverStatus(bool verbose) {
    const auto packages = EnumerateInstalledDriverPackages();

    std::cout << "helper.version=0.1.0-dev.3\n";
    std::cout << "driver.expected_original_inf="
              << Utf8(kExpectedOriginalInf) << "\n";
    std::cout << "driver.expected_provider="
              << Utf8(kExpectedProvider) << "\n";
    std::cout << "driver.expected_version="
              << Utf8(kExpectedDriverVersion) << "\n";
    std::cout << "driver.installed_count="
              << packages.size() << "\n";

    if (packages.empty()) {
        std::cout << "driver.installed=false\n";
        std::cout << "driver.state=not-installed\n";
        std::cout << "result=not-installed\n";
        return 10;
    }

    if (packages.size() > 1) {
        std::cout << "driver.installed=true\n";
        std::cout << "driver.state=multiple-packages\n";
        std::cout << "result=multiple-packages\n";

        if (verbose) {
            std::cout << "\n[driver-packages]\n";
            for (size_t i = 0; i < packages.size(); ++i) {
                PrintDriverPackage(packages[i], i);
            }
        }

        return 13;
    }

    const DriverPackage& package = packages.front();
    const int comparison = CompareVersions(
        package.driverVersion,
        kExpectedDriverVersion);

    std::cout << "driver.installed=true\n";
    std::cout << "driver.published_inf="
              << Utf8(package.publishedInf) << "\n";
    std::cout << "driver.original_inf="
              << Utf8(package.originalInf) << "\n";
    std::cout << "driver.catalog="
              << Utf8(package.originalCatalog) << "\n";
    std::cout << "driver.provider="
              << Utf8(package.provider) << "\n";
    std::cout << "driver.driver_date="
              << Utf8(package.driverDate) << "\n";
    std::cout << "driver.current_version="
              << Utf8(package.driverVersion) << "\n";

    if (comparison == 0) {
        std::cout << "driver.state=current\n";
        std::cout << "result=current\n";
        return 0;
    }

    if (comparison < 0) {
        std::cout << "driver.state=older\n";
        std::cout << "result=older\n";
        return 11;
    }

    std::cout << "driver.state=newer\n";
    std::cout << "result=newer\n";
    return 12;
}

std::string NativeArchitecture() {
    SYSTEM_INFO info{};
    GetNativeSystemInfo(&info);

    switch (info.wProcessorArchitecture) {
    case PROCESSOR_ARCHITECTURE_AMD64:
        return "amd64";
    case PROCESSOR_ARCHITECTURE_ARM64:
        return "arm64";
    case PROCESSOR_ARCHITECTURE_INTEL:
        return "x86";
    default:
        return "unknown";
    }
}

void PrintDevice(const DeviceInfo& device) {
    std::cout << "device.name=" << Utf8(device.name) << "\n";
    std::cout << "device.instance_id=" << Utf8(device.instanceId) << "\n";
    std::cout << "device.inf=" << Utf8(device.infPath) << "\n";
    std::cout << "device.provider=" << Utf8(device.provider) << "\n";
    std::cout << "device.driver_version=" << Utf8(device.driverVersion) << "\n";
    std::cout << "device.devnode_status=";
    if (device.devNodeStatus.has_value()) {
        std::cout << device.devNodeStatus.value();
    }
    std::cout << "\n";
    std::cout << "device.started="
              << (status_binding::IsDevNodeStarted(device.devNodeStatus) ? "true" : "false")
              << "\n";
    std::cout << "device.has_problem="
              << (status_binding::HasDevNodeProblem(device.devNodeStatus) ? "true" : "false")
              << "\n";
    std::cout << "device.problem_code=";
    if (device.problemCode.has_value()) {
        std::cout << device.problemCode.value();
    }
    std::cout << "\n";
    std::cout << "---\n";
}

int Status(bool verbose) {
    const auto devices = EnumeratePresentDevices();

    bool usbPresent = false;
    bool usbPrecision = false;
    bool bluetoothPnpPresent = false;
    bool bluetoothPrecision = false;
    bool upstreamDriverBound = false;

    std::wstring publishedInf;
    std::wstring driverVersion;

    for (const auto& device : devices) {
        if (!IsA3120Related(device)) {
            continue;
        }

        usbPresent = usbPresent || IsUsbA3120(device);
        bluetoothPnpPresent =
            bluetoothPnpPresent || IsBluetoothPnpA3120(device);

        const bool usbPrecisionBound =
            IsUsbPrecisionInterface(device) &&
            IsUpstreamDriverBound(device);
        const bool bluetoothPrecisionBound =
            IsBluetoothPrecisionInterface(device) &&
            IsUpstreamDriverBound(device);

        usbPrecision = usbPrecision || usbPrecisionBound;
        bluetoothPrecision =
            bluetoothPrecision || bluetoothPrecisionBound;

        if (usbPrecisionBound || bluetoothPrecisionBound) {
            upstreamDriverBound = true;

            if (publishedInf.empty() && !device.infPath.empty()) {
                publishedInf = device.infPath;
            }
            if (driverVersion.empty() && !device.driverVersion.empty()) {
                driverVersion = device.driverVersion;
            }
        }
    }

    const auto bluetoothAddress = ExtractBluetoothAddress(devices);
    const BluetoothState bluetooth =
        QueryBluetoothState(bluetoothAddress);

    const bool bluetoothKnown =
        bluetoothPnpPresent || bluetooth.found;

    const bool supportedKnown =
        usbPresent || bluetoothKnown;

    const bool activePrecision =
        (usbPresent && usbPrecision) ||
        (bluetooth.connected && bluetoothPrecision);

    std::cout << "helper.version=0.1.0-dev.3\n";
    std::cout << "os.arch=" << NativeArchitecture() << "\n";
    std::cout << "device.model=" << (supportedKnown ? "A3120" : "not-detected") << "\n";

    std::cout << "usb.present=" << (usbPresent ? "true" : "false") << "\n";
    std::cout << "usb.precision=" << (usbPrecision ? "true" : "false") << "\n";

    // Keep bluetooth.present for compatibility with dev.1.
    // It means the Bluetooth PnP tree is available, NOT necessarily online.
    std::cout << "bluetooth.present=" << (bluetoothPnpPresent ? "true" : "false") << "\n";
    std::cout << "bluetooth.remembered=" << (bluetooth.remembered ? "true" : "false") << "\n";
    std::cout << "bluetooth.paired=" << (bluetooth.paired ? "true" : "false") << "\n";
    std::cout << "bluetooth.connected=" << (bluetooth.connected ? "true" : "false") << "\n";
    std::cout << "bluetooth.precision=" << (bluetoothPrecision ? "true" : "false") << "\n";
    std::cout << "bluetooth.address="
              << Utf8(bluetooth.found
                     ? FormatBluetoothAddress(bluetooth.address)
                     : L"")
              << "\n";

    std::cout << "driver.bound=" << (upstreamDriverBound ? "true" : "false") << "\n";
    std::cout << "driver.published_inf=" << Utf8(publishedInf) << "\n";
    std::cout << "driver.version=" << Utf8(driverVersion) << "\n";

    if (!supportedKnown) {
        std::cout << "result=no-device\n";
    }
    else if (usbPresent && !usbPrecision) {
        std::cout << "result=device-present-but-not-precision\n";
    }
    else if (!usbPresent &&
             bluetoothKnown &&
             !bluetooth.connected) {
        std::cout << "result=paired-not-connected\n";
    }
    else if (bluetooth.connected && !bluetoothPrecision) {
        std::cout << "result=device-present-but-not-precision\n";
    }
    else if (activePrecision) {
        std::cout << "result=ready\n";
    }
    else {
        std::cout << "result=device-present-but-not-precision\n";
    }

    if (verbose) {
        std::cout << "\n[bluetooth-api]\n";
        std::cout << "bluetooth_api.found="
                  << (bluetooth.found ? "true" : "false") << "\n";
        std::cout << "bluetooth_api.name="
                  << Utf8(bluetooth.name) << "\n";
        std::cout << "bluetooth_api.connected="
                  << (bluetooth.connected ? "true" : "false") << "\n";

        std::cout << "\n[relevant-devices]\n";
        for (const auto& device : devices) {
            if (IsA3120Related(device)) {
                PrintDevice(device);
            }
        }
    }

    if (!supportedKnown) {
        return 2;
    }
    if (usbPresent && !usbPrecision) {
        return 3;
    }
    if (!usbPresent && bluetoothKnown && !bluetooth.connected) {
        return 4;
    }
    if (bluetooth.connected && !bluetoothPrecision) {
        return 3;
    }
    if (activePrecision) {
        return 0;
    }
    return 3;
}

void PrintUsage() {
    std::cout
        << "MagicTrackpadHelper 0.1.0-dev.3\n"
        << "Usage:\n"
        << "  MagicTrackpadHelper.exe status\n"
        << "  MagicTrackpadHelper.exe status --verbose\n"
        << "  MagicTrackpadHelper.exe driver-status\n"
        << "  MagicTrackpadHelper.exe driver-status --verbose\n";
}

} // namespace

int wmain(int argc, wchar_t* argv[]) {
    SetConsoleOutputCP(CP_UTF8);

    if (argc < 2) {
        PrintUsage();
        return 64;
    }

    const std::wstring command = ToUpper(argv[1]);

    if (command == L"STATUS") {
        const bool verbose =
            argc >= 3 && ToUpper(argv[2]) == L"--VERBOSE";
        return Status(verbose);
    }

    if (command == L"DRIVER-STATUS") {
        const bool verbose =
            argc >= 3 && ToUpper(argv[2]) == L"--VERBOSE";
        return DriverStatus(verbose);
    }

    PrintUsage();
    return 64;
}
