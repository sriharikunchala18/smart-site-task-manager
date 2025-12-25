// Classification logic for tasks

const categoryKeywords = {
  scheduling: ['meeting', 'schedule', 'call', 'appointment', 'deadline'],
  finance: ['payment', 'invoice', 'bill', 'budget', 'cost', 'expense'],
  technical: ['bug', 'fix', 'error', 'install', 'repair', 'maintain'],
  safety: ['safety', 'hazard', 'inspection', 'compliance', 'ppe']
};

const priorityKeywords = {
  high: ['urgent', 'asap', 'immediately', 'today', 'critical', 'emergency'],
  medium: ['soon', 'this week', 'important', 'tomorrow', 'next week', 'fix', 'bug', 'inspection'],
  low: [] // default
};

const suggestedActions = {
  scheduling: ['Block calendar', 'Send invite', 'Prepare agenda', 'Set reminder'],
  finance: ['Check budget', 'Get approval', 'Generate invoice', 'Update records'],
  technical: ['Diagnose issue', 'Check resources', 'Assign technician', 'Document fix'],
  safety: ['Conduct inspection', 'File report', 'Notify supervisor', 'Update checklist']
};

function extractEntities(text) {
  const entities = [];

  // Extract dates/times (simple regex for demonstration)
  const dateRegex = /\b\d{1,2}\/\d{1,2}\/\d{4}|\btoday\b|\btomorrow\b|\bnext week\b/gi;
  const dates = text.match(dateRegex);
  if (dates) entities.push(...dates);

  // Extract person names (after "with", "by", "assign to")
  const personRegex = /(?:with|by|assign to)\s+([A-Z][a-z]+)/gi;
  let match;
  while ((match = personRegex.exec(text)) !== null) {
    entities.push(match[1]);
  }

  // Extract location references
  const locationRegex = /(?:at|in|to)\s+([A-Z][a-z]+)/gi;
  while ((match = locationRegex.exec(text)) !== null) {
    entities.push(match[1]);
  }

  // Extract nouns and important terms (simplified approach)
  const nounRegex = /\b(bug|invoice|inspection|budget|office|system|materials)\b/gi;
  const nouns = text.match(nounRegex);
  if (nouns) entities.push(...nouns);

  return entities;
}

function classifyTask(title, description) {
  const fullText = `${title} ${description}`.toLowerCase();

  // Determine category
  let category = 'general';
  for (const [cat, keywords] of Object.entries(categoryKeywords)) {
    if (keywords.some(keyword => fullText.includes(keyword))) {
      category = cat;
      break;
    }
  }

  // Determine priority
  let priority = 'low';
  for (const [pri, keywords] of Object.entries(priorityKeywords)) {
    if (keywords.some(keyword => fullText.includes(keyword))) {
      priority = pri;
      break;
    }
  }

  // Extract entities
  const extractedEntities = extractEntities(fullText);

  // Get suggested actions
  const suggestedActionsList = suggestedActions[category] || [];

  return {
    category,
    priority,
    extractedEntities: extractedEntities,
    suggestedActions: suggestedActionsList
  };
}

module.exports = { classifyTask };
