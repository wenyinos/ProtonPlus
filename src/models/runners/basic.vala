namespace ProtonPlus.Models.Runners {
    public abstract class Basic : Runner {
        internal int asset_position { get; set; } // TODO Describe this
        internal string endpoint { get; set; } // TODO Describe this
        internal int page { get; set; } // TODO Describe this

        construct {
            page = 1;
        }

        public abstract string get_directory_name (string release_name);
    }
}