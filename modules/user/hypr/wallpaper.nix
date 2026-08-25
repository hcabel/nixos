{ ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;

      wallpaper = [
        {
          monitor = "*";
          path = "${./saturn-rings.jpg}";
        }
      ];
    };
  };
}
