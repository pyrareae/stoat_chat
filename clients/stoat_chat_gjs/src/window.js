
import GObject from 'gi://GObject';
import Gtk from 'gi://Gtk';

export const StoatChatGjsWindow = GObject.registerClass({
    GTypeName: 'StoatChatGjsWindow',
    Template: 'resource:///com/pyrareae/stoatchatgjs/window.ui',
    InternalChildren: ['label'],
}, class StoatChatGjsWindow extends Gtk.ApplicationWindow {
    constructor(application) {
        super({ application });
    }
});

