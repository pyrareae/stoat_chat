
import GObject from 'gi://GObject';
import Gio from 'gi://Gio';
import Gtk from 'gi://Gtk?version=4.0';

import { StoatChatGjsWindow } from './window.js';

pkg.initGettext();
pkg.initFormat();

export const StoatChatGjsApplication = GObject.registerClass(
    class StoatChatGjsApplication extends Gtk.Application {
        constructor() {
            super({application_id: 'com.pyrareae.stoatchatgjs', flags: Gio.ApplicationFlags.DEFAULT_FLAGS});

            const quit_action = new Gio.SimpleAction({name: 'quit'});
                quit_action.connect('activate', action => {
                this.quit();
            });
            this.add_action(quit_action);
            this.set_accels_for_action('app.quit', ['<primary>q']);

            const show_about_action = new Gio.SimpleAction({name: 'about'});
            show_about_action.connect('activate', action => {
                let aboutParams = {
                    transient_for: this.active_window,
                    modal: true,
                    program_name: 'stoat_chat_gjs',
                    logo_icon_name: 'com.pyrareae.stoatchatgjs',
                    version: '0.1.0',
                    authors: [
                        'Griffin V'
                    ],
                    copyright: '© 2024 Griffin V'
                };
                const aboutDialog = new Gtk.AboutDialog(aboutParams);
                aboutDialog.present();
            });
            this.add_action(show_about_action);
        }

        vfunc_activate() {
            let {active_window} = this;

            if (!active_window)
                active_window = new StoatChatGjsWindow(this);

            active_window.present();
        }
    }
);

export function main(argv) {
    const application = new StoatChatGjsApplication();
    return application.runAsync(argv);
}
