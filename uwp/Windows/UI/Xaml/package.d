module Windows.UI.Xaml;

import winrt;

@uuid("74b861a1-7487-46a9-9a6e-c78b512726c5")
//@WinrtFactory("Windows.UI.Xaml.Application")
interface IApplication : IInspectable
{
extern(Windows):
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
