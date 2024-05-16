import subprocess
import shutil
import time
import os


# Function for copying all the link files in the folder_4
def copy_folder(source_folder, target_folder, files_to_copy):
    for file_name in files_to_copy:
        source_file_path = os.path.join(source_folder, file_name)
        target_file_path = os.path.join(target_folder, file_name)
        try:
            if os.path.exists(source_file_path):
                if os.path.isdir(source_file_path):
                    shutil.copytree(source_file_path, target_file_path)
                    print(f"Files '{file_name}' copied successfully.")
                else:
                    shutil.copy(source_file_path, target_file_path)
                    print(f"File '{file_name}' copied successfully.")
            else:
                print(f"Source file '{file_name}' does not exist.")
        except IOError as e:
            print(f"Unable to copy file '{file_name}': {e}")


# check if the folder already exists, otherwise, it will create it
def create_folder(folder_path):
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)
        print(f"The {folder_path} folder was created")


# check and change the Permission for folders we want in the stage 5 and 7
def grant_modify_rights(folder_paths):
    try:
        # Construct the icacls command to grant permissions to Everyone
        for folder_path in folder_paths:
            command = f"icacls {folder_path} /grant Everyone:(OI)(CI)RW /grant Users:(OI)(CI)RW"
            # Execute the command
            subprocess.run(command, shell=True, check=True)
        print("Read and write permissions granted to Everyone and Users group successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error granting modify rights: {e}")

# We copy different folder in different server for this reason I repeated same code for many times
def main():
    source_files = r'\\Source_Path'
    target_folder = r'C:\Target_Folder'
    files_to_copy_from_folder4 = ['A','B']
    copy_folder(source_files, target_folder, files_to_copy_from_folder4)

    source_files_stage5 = r'\\Source_Path'
    target_folder_stage5 = r'C:\Target_Folder'
    files_to_copy_stage5 = ['A', 'B']
    copy_folder(source_files_stage5, target_folder_stage5, files_to_copy_stage5)

    source_files_stage7 = r'\\Source_Path'
    target_folder_icons7 = r'C:\Target_Folder'
    copy_folder(source_files_stage7, target_folder_icons7, os.listdir(source_files_stage7))

    source_base_stage8 = r'\\Source_Path'
    target_additional_stage8 = r'C:\Target_Folder'
    copy_folder(source_base_stage8, target_additional_stage8, os.listdir(source_base_stage8))

    source_files_stage9 = r'\\Source_Path'
    target_additional_stage9 = r'C:\Target_Folder'
    copy_folder(source_files_stage9, target_additional_stage9, os.listdir(source_files_stage9))

    folder_paths = [r'C:\A', r'C:\B']
    create_folder(folder_paths[0])
    grant_modify_rights(folder_paths)

    time.sleep(60)
    input("Press any key to exit...")


if __name__ == "__main__":
    main()
