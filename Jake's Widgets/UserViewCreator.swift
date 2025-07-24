//
//  UserViewCreator.swift
//  Jake's Widgets
//
//  Created by Jake Huebner on 7/23/25.
//

import SwiftUI

struct UserViewCreator: View
{
    @ObservedObject var viewManager: ViewManager
    let viewIndex: Int
    
    @State private var isSelectingLeft = true
    @State private var showingRenameSheet = false
    @State private var showingDeleteAlert = false
    @State private var newName = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var currentView: WidgetView?
    {
        guard viewIndex < viewManager.widgetViews.count else { return nil }
        return viewManager.widgetViews[viewIndex]
    }
    
    var body: some View
    {
        NavigationView
        {
            ScrollView(.vertical, showsIndicators: false)
            {
                VStack(spacing: 24)
                {
                    // View Info Header
                    VStack(spacing: 12)
                    {
                        if let view = currentView
                        {
                            Text(view.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Customize your StandBy layout")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // Action Buttons
                            HStack(spacing: 16)
                            {
                                Button(action: {
                                    newName = view.name
                                    showingRenameSheet = true
                                })
                                {
                                    HStack
                                    {
                                        Image(systemName: "pencil")
                                        Text("Rename")
                                    }
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                Button(action: {
                                    showingDeleteAlert = true
                                })
                                {
                                    HStack
                                    {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                    }
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Live Preview Section
                    if let view = currentView
                    {
                        VStack(spacing: 16)
                        {
                            Text("Preview")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            // StandBy Preview
                            ViewEditorPreview(view: view)
                            
                            Text("Rotate your phone to see full-screen preview")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Widget Slot Selection
                    if currentView != nil
                    {
                        VStack(spacing: 16)
                        {
                            Text("Edit Widgets")
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            // Left/Right Selection
                            HStack(spacing: 16)
                            {
                                Button(action: { isSelectingLeft = true })
                                {
                                    HStack
                                    {
                                        Image(systemName: "arrow.left")
                                        Text("Left Widget")
                                    }
                                    .foregroundColor(isSelectingLeft ? .white : .blue)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(isSelectingLeft ? Color.blue : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                
                                Button(action: { isSelectingLeft = false })
                                {
                                    HStack
                                    {
                                        Text("Right Widget")
                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundColor(!isSelectingLeft ? .white : .blue)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(!isSelectingLeft ? Color.blue : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // Widget Selection Grid
                    if let view = currentView
                    {
                        VStack(spacing: 16)
                        {
                            Text("Choose \(isSelectingLeft ? "Left" : "Right") Widget")
                                .font(.headline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16)
                            {
                                // Clear/Empty option
                                Button(action: {
                                    if isSelectingLeft
                                    {
                                        viewManager.widgetViews[viewIndex].leftWidget = nil
                                    } else
                                    {
                                        viewManager.widgetViews[viewIndex].rightWidget = nil
                                    }
                                })
                                {
                                    VStack(spacing: 8)
                                    {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemGray4))
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                VStack(spacing: 4)
                                                {
                                                    Image(systemName: "xmark")
                                                        .font(.title2)
                                                        .foregroundColor(.secondary)
                                                    
                                                    Text("Clear")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                }
                                            )
                                        
                                        Text("None")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                
                                // Available widgets
                                ForEach(viewManager.availableWidgets) { widget in
                                    Button(action: {
                                        if isSelectingLeft
                                        {
                                            viewManager.widgetViews[viewIndex].leftWidget = widget
                                        } else
                                        {
                                            viewManager.widgetViews[viewIndex].rightWidget = widget
                                        }
                                    })
                                    {
                                        EditorWidgetCard(
                                            widget: widget,
                                            isSelected: isSelectingLeft ?
                                                view.leftWidget?.id == widget.id :
                                                view.rightWidget?.id == widget.id
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 100) // Tab bar padding
                }
                .padding(.top, 20)
            }
            .navigationTitle("Edit View")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbar
            {
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button("Done")
                    {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingRenameSheet)
        {
            RenameViewSheet(
                currentName: newName,
                onSave: { updatedName in
                    viewManager.renameView(at: viewIndex, newName: updatedName)
                }
            )
        }
        .alert("Delete View", isPresented: $showingDeleteAlert)
        {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive)
            {
                viewManager.deleteView(at: viewIndex)
                dismiss()
            }
        } message:
        {
            Text("Are you sure you want to delete this view? This action cannot be undone.")
        }
    }
}

struct ViewEditorPreview: View
{
    let view: WidgetView
    
    var body: some View
    {
        // Mini StandBy simulation
        ZStack
        {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .frame(width: 280, height: 130)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.systemGray3), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
            
            HStack(spacing: 16)
            {
                // Left widget
                if let leftWidget = view.leftWidget
                {
                    ZStack
                    {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(leftWidget.backgroundColor)
                            .frame(width: 90, height: 90)
                        
                        VStack(spacing: 4)
                        {
                            Image(systemName: leftWidget.iconName)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text(leftWidget.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                } else
                {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(width: 90, height: 90)
                        .overlay(
                            VStack(spacing: 2)
                            {
                                Image(systemName: "plus.circle")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                Text("Empty")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
                
                // Right widget
                if let rightWidget = view.rightWidget
                {
                    ZStack
                    {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(rightWidget.backgroundColor)
                            .frame(width: 90, height: 90)
                        
                        VStack(spacing: 4)
                        {
                            Image(systemName: rightWidget.iconName)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                            
                            Text(rightWidget.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                } else
                {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(width: 90, height: 90)
                        .overlay(
                            VStack(spacing: 2)
                            {
                                Image(systemName: "plus.circle")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                Text("Empty")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
            }
        }
    }
}

struct EditorWidgetCard: View
{
    let widget: Widget
    let isSelected: Bool
    
    var body: some View
    {
        VStack(spacing: 8)
        {
            ZStack
            {
                RoundedRectangle(cornerRadius: 16)
                    .fill(widget.backgroundColor.gradient)
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 4)
                {
                    Image(systemName: widget.iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                    
                    if widget.isNew
                    {
                        Text("NEW")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.white.opacity(0.3))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                
                if isSelected
                {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 100, height: 100)
                }
            }
            
            Text(widget.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 100)
        }
    }
}

struct RenameViewSheet: View
{
    @State private var viewName: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(currentName: String, onSave: @escaping (String) -> Void)
    {
        self._viewName = State(initialValue: currentName)
        self.onSave = onSave
    }
    
    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 24)
            {
                VStack(spacing: 16)
                {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    
                    Text("Rename View")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Give your StandBy layout a new name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                TextField("View Name", text: $viewName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Rename")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button("Cancel")
                    {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button("Save")
                    {
                        onSave(viewName)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(viewName.isEmpty)
                }
            }
        }
    }
}
