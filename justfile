example name:
    #!/bin/fish
    cat examples/{{name}}.vex | nimble --silent run > examples/{{name}}.svg
    open examples/{{name}}.svg
