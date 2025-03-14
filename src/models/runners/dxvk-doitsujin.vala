namespace ProtonPlus.Models.Runners {
    public class DXVK_doitsujin : GitHub {
        public DXVK_doitsujin (Group group) {
            Object (group: group,
                    title: "DXVK (doitsujin)",
                    description: "",
                    endpoint: "https://api.github.com/repos/doitsujin/dxvk/releases",
                    asset_position: 0);
        }

        public override string get_directory_name (string release_name) {
            return release_name.replace ("v", "dxvk-");
        }
    }
}