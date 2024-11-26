

retry=0

while true; do
  # Check if inputs are empty, also rolled the initial input into this function. 
  # Set the message responsible for informing the user that they inputted the function incorrectly the first time to a var that is set to 1
  if [ -z "$dir_name" ] || [ -z "$file_name" ]; then
    if [ "$retry" -eq 1 ]; then
      echo "Both inputs are required to start monitoring the directory properly."
    fi
    echo "Please input the name of the directory you would like to monitor:"
    read dir_name
    echo "Please input the name of the file you would like to write to, (default extension is .txt):"
    read file_name
    retry=1
  else
    echo "Two arguments received!"
    break
  fi
done
# Check if the directory exists
if [ ! -d "$dir_name" ]; then
  echo "Directory '$dir_name' does not exist. Would you like to create it? (Y/y for yes)"
  read input
  if [[ "$input" == "Y" || "$input" == "y" ]]; then
    echo "Please enter the full path where you want to create the directory (or Press Enter to use the current path):"
    read dir_path
    if [ -z "$dir_path" ]; then
      # Use the current directory if no path is provided
      dir_path="."
    fi
    mkdir -p "$dir_path/$dir_name"
    echo "Directory created at '$dir_path/$dir_name'."
  else
	  while true; do
      echo "Did you mean to input the name of an already existing directory? If so, please input the proper name and path:"
      read dir_name
      if [ -d "$dir_name" ]; then
        echo "Directory '$dir_name' exists."
        break
      fi
    done
  fi
fi


echo "Monitoring directory: $dir_name"
#Added a checking for a person doesn't enter a file extension for their initial input
if [[ "$file_name" = *.txt || "$file_name" = *.json || "$file_name" = *.csv ]]; then
echo "Logging events to: $file_name"
else 
 echo "File extension, not included or supported. Defaulting to .txt"
 file_name="${file_name}.txt"
 echo "Logging events to: $file_name"
fi
 

echo "Would you like to monitor all sub-directories? (Y/y)"
read answer

if [[ "$answer" == "Y" || "$answer" == "y" ]]; then
    options="-r"
else
    options=""
fi

# Start monitoring the directory
inotifywait -m $options -e create -e delete -e modify -e move --format '%e, %w%f' "$dir_name" | while read event; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp, $event" >> "$file_name"
done

