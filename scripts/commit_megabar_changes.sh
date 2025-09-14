#!/bin/bash

# MegaBar Development Workflow Script
# Automates the process of committing new development back to the MegaBar engine
#
# USAGE: Run this script from your host application directory
# Expected directory structure:
#   parent_dir/
#   ├── megabar/     # MegaBar engine (../megabar from host app)
#   └── your_app/    # Your host app (current directory)
#
# Example:
#   cd /Users/john/projects/megabar/home22
#   ../megabar/scripts/commit_megabar_changes.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - assumes script is run from host app directory
MEGABAR_ENGINE_PATH="../megabar"
HOST_APP_PATH="$(pwd)"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to get user confirmation
confirm() {
    read -p "$1 (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Function to validate setup
validate_setup() {
    print_status "Validating setup..."
    
    # Check if we're in a Rails app
    if [ ! -f "Gemfile" ] || [ ! -d "config" ]; then
        print_error "This doesn't appear to be a Rails application directory"
        print_error "Please run this script from your host application directory"
        exit 1
    fi
    
    # Check if MegaBar engine exists in parent directory
    if [ ! -d "$MEGABAR_ENGINE_PATH" ]; then
        print_error "MegaBar engine not found at: $MEGABAR_ENGINE_PATH"
        print_error "Expected directory structure:"
        print_error "  parent_dir/"
        print_error "  ├── megabar/     # MegaBar engine"
        print_error "  └── $(basename "$HOST_APP_PATH")/   # Your host app (current directory)"
        exit 1
    fi
    
    print_success "Running from host app: $(basename "$HOST_APP_PATH")"
    print_success "MegaBar engine found at: $MEGABAR_ENGINE_PATH"
}

# Function to copy migrations
copy_migrations() {
    print_status "Copying MegaBar migrations..."
    
    local migration_count=0
    
    # Find and copy MegaBar migrations
    for migration in "db/migrate"/*_megabar_*.rb; do
        if [ -f "$migration" ]; then
            local filename=$(basename "$migration")
            cp "$migration" "$MEGABAR_ENGINE_PATH/db/migrate/"
            print_success "Copied migration: $filename"
            ((migration_count++))
        fi
    done
    
    if [ $migration_count -eq 0 ]; then
        print_warning "No MegaBar migrations found to copy"
    else
        print_success "Copied $migration_count migration(s)"
    fi
}

# Function to copy core MegaBar models and controllers
copy_core_files() {
    print_status "Checking for new core MegaBar files..."
    
    local files_copied=0
    
    # Copy models
    for model in "app/models/mega_bar"/*.rb; do
        if [ -f "$model" ]; then
            local filename=$(basename "$model")
            # Check if it's a new model (not in engine)
            if [ ! -f "$MEGABAR_ENGINE_PATH/app/models/mega_bar/$filename" ]; then
                cp "$model" "$MEGABAR_ENGINE_PATH/app/models/mega_bar/"
                print_success "Copied new model: $filename"
                ((files_copied++))
            fi
        fi
    done
    
    # Copy controllers
    for controller in "app/controllers/mega_bar"/*.rb; do
        if [ -f "$controller" ]; then
            local filename=$(basename "$controller")
            # Check if it's a new controller (not in engine)
            if [ ! -f "$MEGABAR_ENGINE_PATH/app/controllers/mega_bar/$filename" ]; then
                cp "$controller" "$MEGABAR_ENGINE_PATH/app/controllers/mega_bar/"
                print_success "Copied new controller: $filename"
                ((files_copied++))
            fi
        fi
    done
    
    # Copy views (if any custom ones exist)
    if [ -d "app/views/mega_bar" ]; then
        for view_dir in "app/views/mega_bar"/*; do
            if [ -d "$view_dir" ]; then
                local dirname=$(basename "$view_dir")
                # Check if it's a new view directory (not in engine)
                if [ ! -d "$MEGABAR_ENGINE_PATH/app/views/mega_bar/$dirname" ]; then
                    cp -r "$view_dir" "$MEGABAR_ENGINE_PATH/app/views/mega_bar/"
                    print_success "Copied new view directory: $dirname"
                    ((files_copied++))
                fi
            fi
        done
    fi
    
    # Copy test files
    if [ -d "spec/controllers/mega_bar" ]; then
        for spec in "spec/controllers/mega_bar"/*.rb; do
            if [ -f "$spec" ]; then
                local filename=$(basename "$spec")
                if [ ! -f "$MEGABAR_ENGINE_PATH/spec/controllers/mega_bar/$filename" ]; then
                    mkdir -p "$MEGABAR_ENGINE_PATH/spec/controllers/mega_bar"
                    cp "$spec" "$MEGABAR_ENGINE_PATH/spec/controllers/mega_bar/"
                    print_success "Copied new controller spec: $filename"
                    ((files_copied++))
                fi
            fi
        done
    fi
    
    # Copy factories
    if [ -d "spec/internal/factories" ]; then
        for factory in "spec/internal/factories"/*.rb; do
            if [ -f "$factory" ]; then
                local filename=$(basename "$factory")
                if [ ! -f "$MEGABAR_ENGINE_PATH/spec/internal/factories/$filename" ]; then
                    cp "$factory" "$MEGABAR_ENGINE_PATH/spec/internal/factories/"
                    print_success "Copied new factory: $filename"
                    ((files_copied++))
                fi
            fi
        done
    fi
    
    if [ $files_copied -eq 0 ]; then
        print_warning "No new core MegaBar files found to copy"
    else
        print_success "Copied $files_copied new file(s)"
    fi
}

# Function to update seeds
update_seeds() {
    print_status "Updating deterministic seeds..."
    
    # Dump core-only seeds (we're already in host app directory)
    print_status "Dumping core-only seeds (excluding development models)..."
    bundle exec rake mega_bar:dump_deterministic_seeds[mega]
    
    if [ ! -f "db/mega_bar_deterministic.seeds.rb" ]; then
        print_error "Failed to generate seeds file"
        exit 1
    fi
    
    # Show seed changes analysis
    print_status "Analyzing seed changes..."
    
    if [ -f "$MEGABAR_ENGINE_PATH/db/mega_bar_deterministic.seeds.rb" ]; then
        echo -e "\n${YELLOW}=== SEED CHANGES ANALYSIS ===${NC}"
        echo "Changes between current and new seeds:"
        echo
        
        # Show added models
        local added_models=$(diff "$MEGABAR_ENGINE_PATH/db/mega_bar_deterministic.seeds.rb" "db/mega_bar_deterministic.seeds.rb" | grep -E "^\+.*classname" | wc -l)
        echo "New models to be added: $added_models"
        
        # Show added fields
        local added_fields=$(diff "$MEGABAR_ENGINE_PATH/db/mega_bar_deterministic.seeds.rb" "db/mega_bar_deterministic.seeds.rb" | grep -E "^\+.*field:" | wc -l)
        echo "New fields to be added: $added_fields"
        
        # Show detailed diff for new models
        if [ $added_models -gt 0 ]; then
            echo -e "\n${BLUE}New models being added:${NC}"
            diff "$MEGABAR_ENGINE_PATH/db/mega_bar_deterministic.seeds.rb" "db/mega_bar_deterministic.seeds.rb" | grep -E "^\+.*classname" | sed 's/^+//' | head -10
            if [ $added_models -gt 10 ]; then
                echo "... and $((added_models - 10)) more"
            fi
        fi
        
        # Show detailed diff for new fields
        if [ $added_fields -gt 0 ]; then
            echo -e "\n${BLUE}New fields being added:${NC}"
            diff "$MEGABAR_ENGINE_PATH/db/mega_bar_deterministic.seeds.rb" "db/mega_bar_deterministic.seeds.rb" | grep -E "^\+.*field:" | sed 's/^+//' | head -10
            if [ $added_fields -gt 10 ]; then
                echo "... and $((added_fields - 10)) more"
            fi
        fi
        
        echo -e "\n${YELLOW}=== END ANALYSIS ===${NC}\n"
        
        # Interactive approval
        if ! confirm "Do you approve these seed changes?"; then
            print_warning "Seed update cancelled by user"
            return 1
        fi
    else
        print_warning "No existing seeds file found in engine - this will be the initial seeds file"
        if ! confirm "Proceed with creating initial seeds file?"; then
            print_warning "Seed update cancelled by user"
            return 1
        fi
    fi
    
    # Copy seeds to engine
    cp "db/mega_bar_deterministic.seeds.rb" "$MEGABAR_ENGINE_PATH/db/"
    print_success "Updated seeds file"
}

# Function to show git status
show_git_status() {
    print_status "Git status of MegaBar engine:"
    cd "$MEGABAR_ENGINE_PATH"
    git status --short
    cd - > /dev/null
}

# Function to create test app
create_test_app() {
    print_status "Creating test application..."
    
    local test_app_path="../test_megabar_$(date +%Y%m%d_%H%M%S)"
    
    if confirm "Create test app at $test_app_path to verify changes?"; then
        cd ..
        rails new "$(basename "$test_app_path")" --skip-git --skip-bundle
        cd "$test_app_path"
        
        print_status "Adding MegaBar to Gemfile..."
        echo "gem 'megabar', path: '../megabar'" >> Gemfile
        echo "gem 'cccux', path: '../cccux'" >> Gemfile
        
        print_status "Installing gems..."
        bundle install
        
        print_status "Running MegaBar setup..."
        bundle exec rake mega_bar:engine_init
        bundle exec rake cccux:setup
        
        print_status "Test app created at: $test_app_path"
        print_warning "You may want to test the new features manually"
        
        cd - > /dev/null
    fi
}

# Main execution
main() {
    echo -e "${GREEN}=== MegaBar Development Workflow ===${NC}\n"
    
    # No need to validate MEGABAR_ENGINE_PATH here - validate_setup() will do it
    
    # Validate setup
    validate_setup
    
    # Copy migrations
    copy_migrations
    
    # Copy core files
    copy_core_files
    
    # Update seeds (with interactive approval)
    update_seeds
    
    # Show git status
    show_git_status
    
    # Offer to create test app
    create_test_app
    
    echo -e "\n${GREEN}=== Workflow Complete ===${NC}"
    print_status "Next steps:"
    echo "1. Review the changes in the MegaBar engine"
    echo "2. Test the new functionality"
    echo "3. Commit changes to the MegaBar repository"
    echo "4. Tag a new version if needed"
}

# Run main function
main "$@"
