{ slintOverlay, ... }:

{
  overlays = [
    (
      finalPkgs: prevPkgs: {
        # NOP
      }
    )

    slintOverlay
  ];

  config = {
    allowUnfree = true;
  };
}
