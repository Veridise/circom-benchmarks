find ../../tests/vulnerabilities/ -name test.json \
    | xargs  jq '.tests[] | {(.id): {project_path: [(input_filename | split("/") | .[:-1] | join("/")), .main] | join("/") , include_path: "../../tests/libs", skip: false}}' \
    | jq -s add > benchmark_config.json