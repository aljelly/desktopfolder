/*
 * Copyright (c) 2017 José Amuedo (https://github.com/spheras)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 */

/**
 * @class
 * Folder Window that is shown above the desktop to manage files and folders
 */
public class DesktopFolder.DesktopWindow : DesktopFolder.FolderWindow {

    /**
     * @constructor
     * @param FolderManager manager the manager of this window
     */
    public DesktopWindow (FolderManager manager) {
        base (manager);
    }

    protected override void show_popup (Gdk.EventButton event) {
        debug("THIS IS THE OVERRIDED!");
        // debug("evento:%f,%f",event.x,event.y);
        // if(this.menu==null) { // we need the event coordinates for the menu, we need to recreate?!

        // Forcing desktop mode to avoid minimization in certain extreme cases without on_press signal!
        // TODO: Is there a way to make a desktop window resizable and movable?

        this.type_hint                = Gdk.WindowTypeHint.DESKTOP;
        this.context_menu             = new Gtk.Menu ();
        Clipboard.ClipboardManager cm = Clipboard.ClipboardManager.get_for_display ();

        // Creating items (please try and keep these in the same order as appended to the menu)
        var new_item = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_NEW_SUBMENU);

        var new_submenu = new Gtk.Menu ();
        var newfolder_item = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_NEW_FOLDER);
        var emptyfile_item = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_NEW_EMPTY_FILE);
        var newlink_item   = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_NEW_FILE_LINK);
        var newlinkdir_item = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_NEW_FOLDER_LINK);
        var newpanel_item = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_NEW_DESKTOP_FOLDER);
        var newlinkpanel_item = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_LINK_PANEL);
        var newnote_item = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_NEW_NOTE);
        var newphoto_item = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_NEW_PHOTO);

        var aligntogrid_item = new Gtk.CheckMenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_ALIGN_TO_GRID);
        var trash_item = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_REMOVE_DESKTOP_FOLDER);
        var textshadow_item = new Gtk.CheckMenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_TEXT_SHADOW);
        var textbold_item = new Gtk.CheckMenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_TEXT_BOLD);
        var textcolor_item = new MenuItemColor (HEAD_TAGS_COLORS);;
        var backgroundcolor_item = new MenuItemColor (BODY_TAGS_COLORS);;

        // Events (please try and keep these in the same order as appended to the menu)
        newfolder_item.activate.connect (()=>{this.new_folder ((int) event.x, (int) event.y);});
        emptyfile_item.activate.connect (()=>{this.new_text_file ((int) event.x, (int) event.y);});
        newlink_item.activate.connect (()=>{this.new_link ((int) event.x, (int) event.y, false);});
        newlinkdir_item.activate.connect (()=>{this.new_link ((int) event.x, (int) event.y, true);});
        newpanel_item.activate.connect (this.new_desktop_folder);
        newlinkpanel_item.activate.connect (this.new_link_panel);
        newnote_item.activate.connect (this.new_note);
        newphoto_item.activate.connect (this.new_photo);

        ((Gtk.CheckMenuItem) aligntogrid_item).set_active (this.manager.get_settings ().align_to_grid);
        ((Gtk.CheckMenuItem) aligntogrid_item).toggled.connect (this.on_toggle_align_to_grid);
        trash_item.activate.connect (this.manager.trash);
        ((Gtk.CheckMenuItem) textshadow_item).set_active (this.manager.get_settings ().textshadow);
        ((Gtk.CheckMenuItem) textshadow_item).toggled.connect (this.on_toggle_shadow);
        ((Gtk.CheckMenuItem) textbold_item).set_active (this.manager.get_settings ().textbold);
        ((Gtk.CheckMenuItem) textbold_item).toggled.connect (this.on_toggle_bold);
        ((MenuItemColor) textcolor_item).color_changed.connect (change_head_color);
        ((MenuItemColor) backgroundcolor_item).color_changed.connect (change_body_color);

        // Appending (in order)
        if (cm.can_paste) {
            var paste_item = new Gtk.MenuItem.with_label (DesktopFolder.Lang.DESKTOPFOLDER_MENU_PASTE);
            paste_item.activate.connect (this.manager.paste);
            context_menu.append (new MenuItemSeparator ());
            context_menu.append (paste_item);
        }
        context_menu.append (new_item);
        new_item.set_submenu (new_submenu);

        new_submenu.append (newfolder_item);
        new_submenu.append (emptyfile_item);
        new_submenu.append (new MenuItemSeparator ());
        new_submenu.append (newlink_item);
        new_submenu.append (newlinkdir_item);
        new_submenu.append (new MenuItemSeparator ());
        new_submenu.append (newpanel_item);
        new_submenu.append (newlinkpanel_item);
        new_submenu.append (newnote_item);
        new_submenu.append (newphoto_item);

        context_menu.append (new MenuItemSeparator ());
        context_menu.append (aligntogrid_item);
        context_menu.append (new MenuItemSeparator ());
        context_menu.append (trash_item);
        context_menu.append (new MenuItemSeparator ());
        context_menu.append (textshadow_item);
        context_menu.append (textbold_item);
        context_menu.append (new MenuItemSeparator ());
        context_menu.append (textcolor_item);
        context_menu.append (backgroundcolor_item);

        context_menu.show_all ();

        context_menu.popup (
            null, // parent menu shell
            null, // parent menu item
            null, // func
            event.button, // button
            event.get_time () // Gtk.get_current_event_time() // time
        );
    }


}
