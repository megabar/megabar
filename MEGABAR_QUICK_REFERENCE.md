# MegaBar Quick Reference Card

## 🚀 What is MegaBar?
**Dynamic web application builder** that creates complete CRUD interfaces through form-based configuration.

## 🏗️ Core Concept
**Forms → Full Web Applications**
- Fill out model form → Get complete CRUD interface
- Add field forms → Get form fields and displays
- No manual coding required

---

## 📋 Workflow 1: Model Creation

### Input (Model Form)
```ruby
name: "Product"
classname: "Product" 
tablename: "products"
make_page: template_id  # ⭐ KEY: Triggers auto-creation
```

### Auto-Created Output
```
Page (/products) 
→ Layout 
→ LayoutSection 
→ Block 
→ 4 ModelDisplays (index, new, edit, show)
```

### Result
**Complete /products interface** with listing, create, edit, and detail pages.

---

## 📝 Workflow 2: Field Creation  

### Input (Field Form)
```ruby
field: "name"
model_display_ids: [index_id, new_id]  # ⭐ KEY: Multi-select
default_data_format: "textread"         # For show/index  
default_data_format_edit: "textbox"     # For edit/new
```

### Auto-Created Output
```
FieldDisplay (Index): format="textread" (display only)
FieldDisplay (New): format="textbox" (input field)
```

### Result
**"Name" field appears** on index listing (read-only) and new form (editable).

---

## 🔧 Key Features

### Multi-Select Power
Users pick **exactly which pages** each field appears on:
- ✅ Name field → Index + Edit only
- ✅ Description → Show page only  
- ✅ Category → Edit + New forms only

### Smart Format Assignment
Same field, different formats based on context:
- **Edit/New pages**: Uses `default_data_format_edit` (textbox, select, checkbox)
- **Show/Index pages**: Uses `default_data_format` (textread, display formats)

### Complete Automation
One form submission creates **entire relationship chains** automatically.

---

## 🎯 Real Example

### Step 1: Create Product Model
```ruby
MegaBar::Model.create!(name: "Product", make_page: template.id)
```
**Result**: `/products` with index, new, edit, show pages

### Step 2: Add Name Field  
```ruby
MegaBar::Field.create!(
  field: "name",
  model_display_ids: [index_id, new_id, edit_id, show_id]
)
```
**Result**: Name appears on all 4 pages with appropriate formats

### Step 3: Add Category Field
```ruby  
MegaBar::Field.create!(
  field: "category",
  default_data_format_edit: "select",
  model_display_ids: [new_id, edit_id]  # Forms only
)
```
**Result**: Category dropdown on new/edit forms only

---

## 🧪 Testing Strategy

### Integration Tests Verify:
1. **Model creation** → Complete page/layout/block chain  
2. **Field creation** → FieldDisplay auto-creation with correct formats
3. **Multi-select** → Fields appear only where selected
4. **Format logic** → Different formats for edit vs display

### Test Pattern:
```ruby
# Create model with page
model = MegaBar::Model.create!(make_page: template.id)

# Verify 4 ModelDisplays created
expect(model_displays.count).to eq(4)

# Create field for selected displays
field = MegaBar::Field.create!(model_display_ids: [id1, id2])

# Verify FieldDisplays created with correct formats
expect(field_displays.count).to eq(2)
expect(edit_display.format).to eq("textbox")
expect(show_display.format).to eq("textread")
```

---

## 💡 For AIs: Key Understanding Points

1. **MegaBar is form-driven**: Users build apps by filling out forms, not writing code
2. **Relationships auto-create**: One model form creates 6+ related objects automatically  
3. **Multi-select is core**: Field creation lets users choose exactly where fields appear
4. **Format assignment is intelligent**: Same field renders differently based on context
5. **Testing requires callback management**: Disable migration callbacks in test environments

## 🔍 Entry Points for Code Exploration

- **Model creation**: `app/models/mega_bar/model.rb` → `make_page_for_model` method
- **Field creation**: `app/models/mega_bar/field.rb` → `make_field_displays` method  
- **Integration tests**: `spec/integration/model_creation_spec.rb` and `field_creation_spec.rb`
- **Block system**: `app/models/mega_bar/block.rb` and layable relationships 