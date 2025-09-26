package com.mlhealth.app.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import kotlinx.coroutines.delay

// Generic searchable selection dialog
@Composable
fun <T> SearchableSelectionDialog(
    title: String,
    items: List<T>,
    recentItems: List<T> = emptyList(),
    favoriteItems: List<T> = emptyList(),
    onItemSelected: (T) -> Unit,
    onCreateNew: ((String) -> Unit)? = null,
    onDismiss: () -> Unit,
    searchableText: (T) -> String,
    displayName: (T) -> String,
    displaySubtitle: (T) -> String? = { null },
    itemKey: (T) -> Any
) {
    var searchText by remember { mutableStateOf("") }
    val keyboardController = LocalSoftwareKeyboardController.current
    val focusRequester = remember { FocusRequester() }

    // Filter items based on search
    val filteredItems = remember(searchText, items) {
        if (searchText.isEmpty()) {
            items
        } else {
            items.filter {
                searchableText(it).contains(searchText, ignoreCase = true)
            }
        }
    }

    LaunchedEffect(Unit) {
        delay(100)
        focusRequester.requestFocus()
    }

    Dialog(
        onDismissRequest = onDismiss,
        properties = DialogProperties(
            usePlatformDefaultWidth = false,
            dismissOnBackPress = true,
            dismissOnClickOutside = true
        )
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth(0.95f)
                .fillMaxHeight(0.9f),
            shape = RoundedCornerShape(16.dp)
        ) {
            Column(
                modifier = Modifier.fillMaxSize()
            ) {
                // Header with title and close button
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Select $title",
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.Bold
                    )

                    IconButton(onClick = onDismiss) {
                        Icon(Icons.Default.Close, contentDescription = "Close")
                    }
                }

                // Search bar
                OutlinedTextField(
                    value = searchText,
                    onValueChange = { searchText = it },
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .focusRequester(focusRequester),
                    placeholder = { Text("Search $title...") },
                    leadingIcon = {
                        Icon(Icons.Default.Search, contentDescription = null)
                    },
                    trailingIcon = {
                        if (searchText.isNotEmpty()) {
                            IconButton(onClick = { searchText = "" }) {
                                Icon(Icons.Default.Clear, contentDescription = "Clear")
                            }
                        }
                    },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp)
                )

                Spacer(modifier = Modifier.height(8.dp))

                // Content
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .weight(1f),
                    contentPadding = PaddingValues(vertical = 8.dp)
                ) {
                    // Create new option
                    if (searchText.isNotEmpty() && onCreateNew != null) {
                        item {
                            CreateNewItem(
                                text = searchText,
                                title = title,
                                onClick = {
                                    onCreateNew(searchText)
                                    onDismiss()
                                }
                            )
                            Divider(modifier = Modifier.padding(horizontal = 16.dp))
                        }
                    }

                    // Favorites section
                    if (favoriteItems.isNotEmpty() && searchText.isEmpty()) {
                        item {
                            SectionHeader("Favorites")
                        }

                        items(
                            items = favoriteItems,
                            key = itemKey
                        ) { item ->
                            SelectionItem(
                                name = displayName(item),
                                subtitle = displaySubtitle(item),
                                isFavorite = true,
                                onClick = {
                                    onItemSelected(item)
                                    onDismiss()
                                }
                            )
                        }

                        item {
                            Spacer(modifier = Modifier.height(8.dp))
                            Divider(modifier = Modifier.padding(horizontal = 16.dp))
                            Spacer(modifier = Modifier.height(8.dp))
                        }
                    }

                    // Recent section
                    if (recentItems.isNotEmpty() && searchText.isEmpty()) {
                        item {
                            SectionHeader("Recent")
                        }

                        items(
                            items = recentItems.take(5),
                            key = itemKey
                        ) { item ->
                            SelectionItem(
                                name = displayName(item),
                                subtitle = displaySubtitle(item),
                                onClick = {
                                    onItemSelected(item)
                                    onDismiss()
                                }
                            )
                        }

                        item {
                            Spacer(modifier = Modifier.height(8.dp))
                            Divider(modifier = Modifier.padding(horizontal = 16.dp))
                            Spacer(modifier = Modifier.height(8.dp))
                        }
                    }

                    // All items / Search results
                    item {
                        SectionHeader(if (searchText.isEmpty()) "All $title" else "Search Results")
                    }

                    if (filteredItems.isEmpty()) {
                        item {
                            EmptySearchResult(searchText, title)
                        }
                    } else {
                        items(
                            items = filteredItems,
                            key = itemKey
                        ) { item ->
                            SelectionItem(
                                name = displayName(item),
                                subtitle = displaySubtitle(item),
                                onClick = {
                                    onItemSelected(item)
                                    onDismiss()
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun SectionHeader(title: String) {
    Text(
        text = title,
        style = MaterialTheme.typography.titleMedium,
        fontWeight = FontWeight.Bold,
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
        color = MaterialTheme.colorScheme.primary
    )
}

@Composable
private fun SelectionItem(
    name: String,
    subtitle: String?,
    isFavorite: Boolean = false,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = name,
                style = MaterialTheme.typography.bodyLarge,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            subtitle?.let {
                Text(
                    text = it,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        if (isFavorite) {
            Icon(
                Icons.Default.Star,
                contentDescription = "Favorite",
                tint = Color(0xFFFFC107),
                modifier = Modifier
                    .size(18.dp)
                    .padding(end = 8.dp)
            )
        }

        Icon(
            Icons.Default.ChevronRight,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.size(20.dp)
        )
    }
}

@Composable
private fun CreateNewItem(
    text: String,
    title: String,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            Icons.Default.Add,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary,
            modifier = Modifier
                .size(40.dp)
                .clip(RoundedCornerShape(8.dp))
                .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.1f))
                .padding(8.dp)
        )

        Spacer(modifier = Modifier.width(12.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = "Create \"$text\"",
                style = MaterialTheme.typography.bodyLarge
            )
            Text(
                text = "Add as custom $title",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun EmptySearchResult(
    searchText: String,
    itemType: String
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            Icons.Default.SearchOff,
            contentDescription = null,
            modifier = Modifier.size(64.dp),
            tint = MaterialTheme.colorScheme.onSurfaceVariant
        )

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = "No ${itemType.lowercase()} found",
            style = MaterialTheme.typography.titleMedium
        )

        Spacer(modifier = Modifier.height(4.dp))

        Text(
            text = "No results for \"$searchText\"",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}