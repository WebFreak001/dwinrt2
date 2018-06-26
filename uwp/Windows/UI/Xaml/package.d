module Windows.UI.Xaml;

import winrt;

@uuid("74b861a1-7487-46a9-9a6e-c78b512726c5")
interface IApplication : IInspectable
{
extern (Windows):
	HRESULT get_Resources(void** return_value);
	HRESULT set_Resources(void* value);
	HRESULT get_DebugSettings(void** return_value);
	HRESULT get_RequestedTheme(void** return_value);
	HRESULT set_RequestedTheme(void* value);
	HRESULT add_UnhandledException(void* value, EventRegistrationToken* return_token);
	HRESULT remove_UnhandledException(EventRegistrationToken token);
	HRESULT add_Suspending(void* value, EventRegistrationToken* return_token);
	HRESULT remove_Suspending(EventRegistrationToken token);
	HRESULT add_Resuming(void* value, EventRegistrationToken* return_token);
	HRESULT remove_Resuming(EventRegistrationToken token);
	HRESULT abi_Exit();
}

@uuid("25f99ff7-9347-459a-9fac-b2d0e11c1a0f")
interface IApplicationOverrides : IInspectable
{
extern (Windows):
	HRESULT abi_OnActivated(void* args);
	HRESULT abi_OnLaunched(void* args);
	HRESULT abi_OnFileActivated(void* args);
	HRESULT abi_OnSearchActivated(void* args);
	HRESULT abi_OnShareTargetActivated(void* args);
	HRESULT abi_OnFileOpenPickerActivated(void* args);
	HRESULT abi_OnFileSavePickerActivated(void* args);
	HRESULT abi_OnCachedFileUpdaterActivated(void* args);
	HRESULT abi_OnWindowCreated(void* args);
}

@uuid("93bbe361-be5a-4ee3-b4a3-95118dc97a89")
interface IApplicationFactory : IInspectable
{
extern (Windows):
	HRESULT abi_CreateInstance(IInspectable outer, IInspectable* inner, Windows.UI.Xaml.Application* instance);
}

@WinrtFactory!IApplicationFactory
@winrtImplements("IApplication", "IApplicationOverrides")
abstract class Application : RuntimeClass
{
	final void* Resources() @property const { void* ret; auto res = __inner.as!IApplication.get_Resources(&ret); Debug.OK(res); return ret; }
	final void Resources(void* value) @property { auto res = __inner.as!IApplication.set_Resources(value); Debug.OK(res); }
	final void* DebugSettings() @property const { void* ret; auto res = __inner.as!IApplication.get_DebugSettings(&ret); Debug.OK(res); return ret; }
	final void* RequestedTheme() @property const { void* ret; auto res = __inner.as!IApplication.get_RequestedTheme(&ret); Debug.OK(res); return ret; }
	final void RequestedTheme(void* value) @property const { auto res = __inner.as!IApplication.set_RequestedTheme(value); Debug.OK(res); }
	final EventRegistrationToken OnUnhandledException(void* value) { EventRegistrationToken ret; auto res = __inner.as!IApplication.add_UnhandledException(value, &ret); Debug.OK(res); return ret; }
	final void RemoveUnhandledException(EventRegistrationToken token) { auto res = __inner.as!IApplication.remove_UnhandledException(token); Debug.OK(res); }
	final EventRegistrationToken OnSuspending(void* value) { EventRegistrationToken ret; auto res = __inner.as!IApplication.add_Suspending(value, &ret); Debug.OK(res); return ret; }
	final void RemoveSuspending(EventRegistrationToken token) { auto res = __inner.as!IApplication.remove_Suspending(token); Debug.OK(res); }
	final EventRegistrationToken OnResuming(void* value) { EventRegistrationToken ret; auto res = __inner.as!IApplication.add_Resuming(value, &ret); Debug.OK(res); return ret; }
	final void RemoveResuming(EventRegistrationToken token) { auto res = __inner.as!IApplication.remove_Resuming(token); Debug.OK(res); }
	final void Exit() { auto res = __inner.as!IApplication.abi_Exit(); Debug.OK(res); }

	void OnActivated(void* args) { auto res = __inner.as!IApplicationOverrides.abi_OnActivated(args); Debug.OK(res); }
	void OnLaunched(void* args) { auto res = __inner.as!IApplicationOverrides.abi_OnLaunched(args); Debug.OK(res); }
	void OnFileActivated(void* args) { auto res = __inner.as!IApplicationOverrides.abi_OnFileActivated(args); Debug.OK(res); }
	void OnSearchActivated(void* args) { auto res = __inner.as!IApplicationOverrides.abi_OnSearchActivated(args); Debug.OK(res); }
	void OnShareTargetActivated(void* args) { auto res = __inner.as!IApplicationOverrides.abi_OnShareTargetActivated(args); Debug.OK(res); }
	void OnFileOpenPickerActivated(void* args) { auto res = __inner.as!IApplicationOverrides.abi_OnFileOpenPickerActivated(args); Debug.OK(res); }
	void OnFileSavePickerActivated(void* args) { auto res = __inner.as!IApplicationOverrides.abi_OnFileSavePickerActivated(args); Debug.OK(res); }
	void OnCachedFileUpdaterActivated(void* args) { auto res = __inner.as!IApplicationOverrides.abi_OnCachedFileUpdaterActivated(args); Debug.OK(res); }
	void OnWindowCreated(void* args) { auto res = __inner.as!IApplicationOverrides.abi_OnWindowCreated(args); Debug.OK(res); }
}

// TODO: implement IActivationFactory for statics
@uuid("06499997-f7b4-45fe-b763-7577d1d3cb4a")
interface IApplicationStatics : IInspectable
{
extern(Windows):
	HRESULT get_Current(Application* value);
	HRESULT abi_Start(void function(void* args) callback);
	HRESULT abi_LoadComponent(IInspectable component, void** resourceLocator);
	HRESULT abi_LoadComponentWithResourceLocation(IInspectable component, void** resourceLocator, uint componentResourceLocation);
}
