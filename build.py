import os

FILE_LIST_PLACEHOLDER = "--%REPLACE_ME%"

FILE_EXCLUDE = ".exclude"
FILE_SETUP_TEMPLATE = "setup.template.lua"
FILE_SETUP = "setup.lua"
FILE_UNINSTALL_TEMPLATE = "uninstall.template.lua"
FILE_UNINSTALL = "uninstall.lua"

def normalizePath(path):
    return path.replace("\\", "/")

def createFileFromTemplate(file_name, template_file_name, placeholder, value):
    template = open(template_file_name)
    template_content = template.read()
    template.close()

    file_content = template_content.replace(placeholder, value)

    result_file = open(file_name, "w")
    result_file.write(file_content)
    result_file.flush()
    result_file.close()

def main():
    excluded_files = []
    excluded_folders = []

    if os.path.exists(FILE_EXCLUDE):
        f = open(FILE_EXCLUDE)
        excluded_files.extend(list(map(str.strip, f.read().split('\n'))))
        f.close()

        excluded_files = [x for x in excluded_files if x != "" and not x.startswith('#')]
        excluded_files = [normalizePath(x) for x in excluded_files]

        excluded_folders = [x for x in excluded_files if x.endswith('/')]

    file_list = []
    root_dir = os.path.dirname(os.path.abspath(__file__))
    
    for root, dirs, files in os.walk(root_dir):
        # skips folders that start with a '.' (like .git, etc.) or are in the exclude list
        for d in list(dirs):
            script_dir = normalizePath(os.path.dirname(os.path.abspath(__file__))) + "/"
            base_path = normalizePath(os.path.join(root, d)).replace(script_dir, "") + "/"
            if d.startswith('.') or base_path in excluded_folders:
                dirs.remove(d)

        for f in files:
            if not f.startswith('.'):
                file_name = os.path.relpath(os.path.join(root, f), root_dir)
                file_list.append(normalizePath(file_name))
                
    file_list_setup = [x for x in file_list if x not in excluded_files]

    if FILE_UNINSTALL not in file_list_setup:
        file_list_setup.append(FILE_UNINSTALL)

    file_list_uninstall = file_list_setup.copy()
    file_list_uninstall.append(FILE_SETUP)
    
    rendered_file_list_setup = "\n".join(f"    \"{file}\"," for file in file_list_setup)
    rendered_file_list_setup = rendered_file_list_setup.rstrip(",")

    rendered_file_list_uninstall = "\n".join(f"    \"{file}\"," for file in file_list_uninstall)
    rendered_file_list_uninstall = rendered_file_list_uninstall.rstrip(",")

    createFileFromTemplate(os.path.join(root_dir, FILE_SETUP), os.path.join(root_dir, FILE_SETUP_TEMPLATE), FILE_LIST_PLACEHOLDER, rendered_file_list_setup)
    createFileFromTemplate(os.path.join(root_dir, FILE_UNINSTALL), os.path.join(root_dir, FILE_UNINSTALL_TEMPLATE), FILE_LIST_PLACEHOLDER, rendered_file_list_uninstall)

main()