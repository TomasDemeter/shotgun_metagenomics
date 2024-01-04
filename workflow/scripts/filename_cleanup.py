import os

# Define the path to the directory
path = '../../inputs/full_sequences/'

# Read the metadata file
with open(os.path.join(path, 'metadata.csv'), 'r') as f:
    lines = f.readlines()

# Create a dictionary to map ids to names
id_to_name = {line.split('_')[0]: line.strip() for line in lines}

# Iterate over all files in the directory
for filename in os.listdir(path):
    if filename.endswith('.fq.gz'):
        # Extract the id from the filename
        id = filename.split('-')[1].split('_')[0]
        
        # Check if this id is in our dictionary
        if id in id_to_name:
            # Construct the new filename
            new_filename = id_to_name[id] + '_' + filename.split('_')[-1]
            # Rename the file
            os.rename(os.path.join(path, filename), os.path.join(path, new_filename))
