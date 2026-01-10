# SPDX-FileCopyrightText: 2026 Chris Chambers
# SPDX-License-Identifier: MIT
{
  description = "A collection of project templates";

  outputs =
    { ... }:
    {
      templates = {
        python = {
          path = ./python;
          description = "Python dev environment (uv)";
        };
        clojure = {
          path = ./clojure;
          description = "Clojure dev environment";
        };
      };
    };
}
