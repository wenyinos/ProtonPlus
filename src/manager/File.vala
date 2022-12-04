namespace ProtonPlus.Manager {
    public class File {
        public static string Extract (string install_location, string tool_name) {
            const int bufferSize = 192000;

            var archive = new Archive.Read ();
            archive.support_format_all ();
            archive.support_filter_all ();

            int flags;
            flags = Archive.ExtractFlags.ACL;
            flags |= Archive.ExtractFlags.PERM;
            flags |= Archive.ExtractFlags.TIME;
            flags |= Archive.ExtractFlags.FFLAGS;

            var ext = new Archive.WriteDisk ();
            ext.set_standard_lookup ();
            ext.set_options (flags);

            if (archive.open_filename (install_location + tool_name + ".tar.gz", bufferSize) != Archive.Result.OK) return "";

            ssize_t r;

            unowned Archive.Entry entry;

            string sourcePath = "";
            bool firstRun = true;

            for ( ;; ) {
                r = archive.next_header (out entry);
                if (r == Archive.Result.EOF) break;
                if (r < Archive.Result.OK) stderr.printf (ext.error_string ());
                if (r < Archive.Result.WARN) return "";
                if (firstRun) {
                    sourcePath = entry.pathname ();
                    firstRun = false;
                }
                entry.set_pathname (install_location + entry.pathname ());
                r = ext.write_header (entry);
                if (r < Archive.Result.OK) stderr.printf (ext.error_string ());
                else if (entry.size () > 0) {
                    r = copy_data (archive, ext);
                    if (r < Archive.Result.WARN) return "";
                }
                r = ext.finish_entry ();
                if (r < Archive.Result.OK) stderr.printf (ext.error_string ());
                if (r < Archive.Result.WARN) return "";
            }

            archive.close ();

            Delete (install_location + tool_name + ".tar.gz");

            return install_location + sourcePath;
        }

        static ssize_t copy_data (Archive.Read ar, Archive.WriteDisk aw) {
            ssize_t r;
            uint8[] buffer;
            Archive.int64_t offset;

            for ( ;; ) {
                r = ar.read_data_block (out buffer, out offset);
                if (r == Archive.Result.EOF) return (Archive.Result.OK);
                if (r < Archive.Result.OK) return (r);
                r = aw.write_data_block (buffer, offset);
                if (r < Archive.Result.OK) {
                    stderr.printf (aw.error_string ());
                    return (r);
                }
            }
        }

        public static void Delete (string path) {
            try {
                var file = GLib.File.new_for_path (path);
                file.trash ();
            } catch (GLib.Error e) {
                stderr.printf (e.message + "\n");
            }
        }

        public static void Rename (string sourcePath, string destinationPath) {
            try {
                var fileSource = GLib.File.new_for_path (sourcePath);
                var fileDest = GLib.File.new_for_path (destinationPath);
                fileSource.move (fileDest, FileCopyFlags.NONE, null, null);
            } catch (GLib.Error e) {
                stderr.printf (e.message + "\n");
            }
        }

        public static void Write (string path, string content) {
            try {
                var file = GLib.File.new_for_path (path);
                FileOutputStream os = file.create (FileCreateFlags.PRIVATE);
                os.write (content.data);
            } catch (GLib.Error e) {
                stderr.printf (e.message + "\n");
            }
        }

        public static void CreateDirectory (string path) {
            try {
                var file = GLib.File.new_for_path (path);
                file.make_directory ();
            } catch (GLib.Error e) {
                stderr.printf (e.message + "\n");
            }
        }

        public static bool VerifyDirectoryExist (string path) {
            try {
                var file = GLib.File.new_for_path (path);
                if (file.query_exists ()) {
                    var info = file.query_info ("standard::*", FileQueryInfoFlags.NONE);
                    if (info.get_file_type () == FileType.DIRECTORY) return true;
                }
                return false;
            } catch (GLib.Error e) {
                stderr.printf (e.message + "\n");
                return false;
            }
        }
    }
}
