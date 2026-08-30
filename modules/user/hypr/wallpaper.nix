{ ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;

      wallpaper = [
        {
          monitor = "*";
          path = "${../quickshell/qs/saturn-rings.jpg}";
        }
      ];
    };
  };
}
