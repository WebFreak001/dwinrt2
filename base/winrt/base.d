module winrt.base;

public import core.sys.windows.windows;
public import winrt.hstring;
public import winrt.uuid;

import winrt.debugutils;

pragma(lib, "User32");
pragma(lib, "windowsapp");
pragma(lib, "uuid");

enum ApartmentType
{
	singleThreaded,
	multiThreaded
}

enum TrustLevel
{
	BaseTrust,
	PartialTrust,
	FullTrust
}

struct EventRegistrationToken
{
	long value;
}

@uuid("c03f6a43-65a4-9818-987e-e0b810d2a6f2")
interface IAgileReference : IUnknown
{
extern (Windows):
	HRESULT abi_Resolve(REFIID riid, void** ppvObjectReference);
}

extern (Windows)
{
	HRESULT GetRestrictedErrorInfo(IRestrictedErrorInfo* info);
	HRESULT RoGetActivationFactory(HSTRING classId, const ref GUID iid, IInspectable* factory);
	HRESULT RoInitialize(uint type);
	BOOL RoOriginateError(HRESULT error, HSTRING message);
	void RoUninitialize();
	HRESULT SetRestrictedErrorInfo(IRestrictedErrorInfo info);
	HRESULT CoGetApartmentType(int* pAptType, int* pAptQualifier);
	HRESULT RoGetAgileReference(int options, REFIID riid, IUnknown pUnk,
			IAgileReference* ppAgileReference);
	HRESULT RoActivateInstance(HSTRING activatableClassId, IInspectable* instance);
}

pragma(inline, true) void init_apartment(in ApartmentType type = ApartmentType.multiThreaded)
{
	debug (DWinRT)
		Debug.WriteLine("RoInitialize %s", type);
	auto hr = RoInitialize(cast(uint) type);
	Debug.OK(hr);
}

pragma(inline, true) void uninit_apartment()
{
	debug (DWinRT)
		Debug.WriteLine("RoUninitialize");
	RoUninitialize();
}

@uuid("af86e2e0-b12d-4c6a-9c5a-d7aa65101e90")
interface IInspectable : IUnknown
{
extern (Windows):
	HRESULT abi_GetIids(ULONG* iidCount, GUID** iids);
	HRESULT abi_GetRuntimeClassName(HSTRING* className);
	HRESULT abi_GetTrustLevel(TrustLevel* trustLevel);
}

Inspectable roActivateInstance(wstring className)
{
	auto name = hstring(className);
	IInspectable inst;
	auto hr = RoActivateInstance(name.handle, &inst);
	Debug.OK(hr);
	return Inspectable(inst);
}

Inspectable factory(wstring className, GUID interfaceID)
{
	auto name = hstring(className);
	IInspectable inst;
	auto hr = RoGetActivationFactory(name.handle, interfaceID, &inst);
	Debug.OK(hr);
	return Inspectable(inst);
}

struct Inspectable
{
	IInspectable handle;

	bool has(T : IUnknown)()
	{
		return hasUUID(uuidOf!T);
	}

	bool hasUUID(GUID uuid)
	{
		ULONG count;
		GUID* iids;
		auto hr = handle.abi_GetIids(&count, &iids);
		Debug.OK(hr);
		foreach (iid; iids[0 .. count])
			if (iid == uuid)
				return true;
		return false;
	}

	T as(T : IUnknown)()
	{
		debug assert(has!T);
		T ret;
		auto hr = handle.QueryInterface(uuidOf!T, cast(void**) &ret);
		Debug.OK(hr);
		return ret;
	}
}
