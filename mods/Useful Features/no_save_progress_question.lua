if RequiredScript == "lib/managers/menumanager" then
	function MenuCallbackHandler:quit_game()
		local dialog_data = {}
		dialog_data.title = managers.localization:text("dialog_warning_title")
		dialog_data.text = managers.localization:text("dialog_are_you_sure_you_want_to_quit")
		local yes_button = {}
		yes_button.text = managers.localization:text("dialog_yes")
		yes_button.callback_func = callback(self, self, "_dialog_save_progress_backup_yes")
		local no_button = {}
		no_button.text = managers.localization:text("dialog_no")
		no_button.callback_func = callback(self, self, "_dialog_quit_no")
		no_button.cancel_button = true
		dialog_data.button_list = {yes_button, no_button}
		managers.system_menu:show(dialog_data)
	end
end