const { classifyTask } = require('../utils/classification');

describe('Task Classification', () => {
  test('should classify scheduling tasks correctly', () => {
    const result = classifyTask('Schedule a meeting with John tomorrow');
    expect(result.category).toBe('scheduling');
    expect(result.priority).toBe('medium');
    expect(result.extractedEntities).toContain('tomorrow');
    expect(result.extractedEntities).toContain('john');
    expect(result.suggestedActions).toContain('Block calendar');
  });

  test('should classify finance tasks correctly', () => {
    const result = classifyTask('Pay the invoice for materials urgently');
    expect(result.category).toBe('finance');
    expect(result.priority).toBe('high');
    expect(result.extractedEntities).toContain('invoice');
    expect(result.suggestedActions).toContain('Check budget');
  });

  test('should classify technical tasks correctly', () => {
    const result = classifyTask('Fix the bug in the system');
    expect(result.category).toBe('technical');
    expect(result.priority).toBe('medium');
    expect(result.extractedEntities).toContain('bug');
    expect(result.suggestedActions).toContain('Diagnose issue');
  });

  test('should classify safety tasks correctly', () => {
    const result = classifyTask('Conduct safety inspection');
    expect(result.category).toBe('safety');
    expect(result.priority).toBe('medium');
    expect(result.extractedEntities).toContain('inspection');
    expect(result.suggestedActions).toContain('Conduct inspection');
  });

  test('should classify general tasks correctly', () => {
    const result = classifyTask('General task description');
    expect(result.category).toBe('general');
    expect(result.priority).toBe('low');
  });

  test('should assess priority correctly', () => {
    expect(classifyTask('Urgent meeting today').priority).toBe('high');
    expect(classifyTask('Schedule meeting soon').priority).toBe('medium');
    expect(classifyTask('Regular maintenance task').priority).toBe('low');
  });

  test('should extract entities correctly', () => {
    const result = classifyTask('Meet with Sarah at office tomorrow for budget review');
    expect(result.extractedEntities).toContain('tomorrow');
    expect(result.extractedEntities).toContain('sarah');
    expect(result.extractedEntities).toContain('office');
    expect(result.extractedEntities).toContain('budget');
  });
});
