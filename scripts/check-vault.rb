#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path('..', __dir__)
tracked = IO.popen(
  ['git', '-C', root, 'ls-files', '--cached', '--others', '--exclude-standard', '-z', '--', '*.md'],
  &:read
)
files = tracked.split("\0").reject(&:empty?).map { |path| File.join(root, path) }.sort
relative = files.to_h { |path| [path.delete_prefix("#{root}/").sub(/\.md\z/, ''), true] }
by_basename = files.group_by { |path| File.basename(path, '.md') }
errors = []

files.each do |path|
  rel_path = path.delete_prefix("#{root}/")
  lines = File.readlines(path, encoding: 'UTF-8')

  fence_count = lines.count { |line| line.start_with?('```') }
  errors << "#{rel_path}: unbalanced fenced code blocks" if fence_count.odd?

  lines.each_with_index do |line, index|
    line.scan(/\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]/).flatten.each do |raw|
      target = raw.strip
      next if target.match?(/[{}*]/)

      from_dir = File.dirname(rel_path)
      local = File.expand_path(target, File.join(root, from_dir)).delete_prefix("#{root}/")
      resolved = relative[target] || relative[local] ||
                 relative["#{target}/INDEX"] || relative["#{local}/INDEX"] ||
                 by_basename.fetch(target, []).length == 1
      errors << "#{rel_path}:#{index + 1}: unresolved wikilink [[#{target}]]" unless resolved
    end

    if line.match?(/(?:curl|wget)[^\n|]*\|\s*(?:ba)?sh\b/)
      errors << "#{rel_path}:#{index + 1}: remote content is piped directly to a shell"
    end

    if line.match?(/-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/)
      errors << "#{rel_path}:#{index + 1}: private-key material detected"
    end
  end
end

if errors.empty?
  puts "Vault check passed: #{files.length} Markdown files"
  exit 0
end

warn errors.join("\n")
warn "Vault check failed: #{errors.length} issue(s)"
exit 1
